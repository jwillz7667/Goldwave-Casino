const WebSocket = require('ws');
const fs = require('fs');
const https = require('https');
const Redis = require('ioredis');
const mysql = require('mysql2/promise');

// Load configurations
const config = require('./socket_config.json');

// SSL configuration
const ssl_options = {
    cert: fs.readFileSync('./ssl/crt.crt'),
    key: fs.readFileSync('./ssl/key.key')
};

// Create Redis client
const redis = new Redis({
    host: '127.0.0.1',
    port: 6379
});

// MySQL pool configuration
const pool = mysql.createPool({
    host: '127.0.0.1',
    user: 'casino_user',
    password: 'strong_password',
    database: 'casino_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Create HTTPS server
const server = https.createServer(ssl_options);

// Create WebSocket server
const wss = new WebSocket.Server({ server });

// Store active game sessions
const activeSessions = new Map();

// WebSocket connection handler
wss.on('connection', async (ws, req) => {
    console.log('New slots client connected');
    
    ws.isAlive = true;
    ws.on('pong', () => { ws.isAlive = true; });

    // Handle incoming messages
    ws.on('message', async (message) => {
        try {
            const data = JSON.parse(message);
            
            switch(data.type) {
                case 'init_game':
                    await initializeGame(ws, data);
                    break;
                    
                case 'spin':
                    await handleSpin(ws, data);
                    break;
                    
                case 'collect':
                    await handleCollect(ws, data);
                    break;
                    
                default:
                    ws.send(JSON.stringify({
                        type: 'error',
                        message: 'Unknown message type'
                    }));
            }
        } catch (error) {
            console.error('Error processing message:', error);
            ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid message format'
            }));
        }
    });

    // Handle client disconnect
    ws.on('close', () => {
        if (ws.sessionId) {
            activeSessions.delete(ws.sessionId);
        }
        console.log('Slots client disconnected');
    });
});

// Initialize game session
async function initializeGame(ws, data) {
    try {
        // Verify user and game
        const [game] = await pool.execute(
            'SELECT * FROM games WHERE id = ? AND status = 1',
            [data.gameId]
        );

        if (game.length === 0) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid game'
            }));
        }

        // Create game session
        const [session] = await pool.execute(
            'INSERT INTO game_sessions (user_id, game_id, status) VALUES (?, ?, "active")',
            [data.userId, data.gameId]
        );

        ws.sessionId = session.insertId;
        ws.userId = data.userId;
        activeSessions.set(session.insertId, {
            userId: data.userId,
            gameId: data.gameId,
            balance: 0,
            lastSpin: null
        });

        ws.send(JSON.stringify({
            type: 'game_initialized',
            sessionId: session.insertId,
            game: game[0]
        }));
    } catch (error) {
        console.error('Game initialization error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to initialize game'
        }));
    }
}

// Handle spin action
async function handleSpin(ws, data) {
    try {
        const session = activeSessions.get(ws.sessionId);
        if (!session) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid session'
            }));
        }

        // Verify bet amount
        const [game] = await pool.execute(
            'SELECT min_bet, max_bet FROM games WHERE id = ?',
            [session.gameId]
        );

        if (data.bet < game[0].min_bet || data.bet > game[0].max_bet) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid bet amount'
            }));
        }

        // Generate spin result
        const result = generateSpinResult(game[0]);
        
        // Update session
        session.lastSpin = {
            bet: data.bet,
            result: result
        };
        
        // Record spin in database
        await pool.execute(
            'INSERT INTO game_rounds (session_id, bet_amount, result) VALUES (?, ?, ?)',
            [ws.sessionId, data.bet, JSON.stringify(result)]
        );

        ws.send(JSON.stringify({
            type: 'spin_result',
            result: result
        }));
    } catch (error) {
        console.error('Spin error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to process spin'
        }));
    }
}

// Generate spin result
function generateSpinResult(game) {
    // This is a simplified example. In production, you would implement
    // proper RNG and game-specific logic here
    const symbols = ['7', 'BAR', 'CHERRY', 'LEMON', 'ORANGE'];
    const reels = [];
    
    for (let i = 0; i < 5; i++) {
        const reel = [];
        for (let j = 0; j < 3; j++) {
            reel.push(symbols[Math.floor(Math.random() * symbols.length)]);
        }
        reels.push(reel);
    }
    
    return {
        reels: reels,
        winLines: calculateWinLines(reels)
    };
}

// Calculate winning lines
function calculateWinLines(reels) {
    // This is a simplified example. In production, you would implement
    // proper win line calculation logic here
    const winLines = [];
    
    // Check middle line
    const middleLine = reels.map(reel => reel[1]);
    if (new Set(middleLine).size === 1) {
        winLines.push({
            line: 1,
            symbols: middleLine,
            multiplier: 5
        });
    }
    
    return winLines;
}

// Handle collect action
async function handleCollect(ws, data) {
    try {
        const session = activeSessions.get(ws.sessionId);
        if (!session || !session.lastSpin) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'No win to collect'
            }));
        }

        // Calculate win amount
        const winAmount = calculateWinAmount(session.lastSpin);
        
        // Update user balance
        await pool.execute(
            'UPDATE users SET balance = balance + ? WHERE id = ?',
            [winAmount, session.userId]
        );

        session.lastSpin = null;
        
        ws.send(JSON.stringify({
            type: 'collect_success',
            amount: winAmount
        }));
    } catch (error) {
        console.error('Collect error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to collect win'
        }));
    }
}

// Calculate win amount
function calculateWinAmount(spin) {
    let totalWin = 0;
    for (const line of spin.result.winLines) {
        totalWin += spin.bet * line.multiplier;
    }
    return totalWin;
}

// Connection health check
const interval = setInterval(() => {
    wss.clients.forEach((ws) => {
        if (ws.isAlive === false) return ws.terminate();
        ws.isAlive = false;
        ws.ping(() => {});
    });
}, 30000);

// Start the server
const PORT = process.env.PORT || config.port;
server.listen(PORT, () => {
    console.log(`Slots server is running on port ${PORT}`);
}); 