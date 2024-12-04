const WebSocket = require('ws');
const fs = require('fs');
const https = require('https');
const Redis = require('ioredis');
const mysql = require('mysql2/promise');
const path = require('path');

// Load configurations
const config = require('./arcade_config.json');

// SSL configuration
const ssl_options = {
    cert: fs.readFileSync(path.join(__dirname, 'ssl', 'crt.crt')),
    key: fs.readFileSync(path.join(__dirname, 'ssl', 'key.key'))
};

// Create Redis client
const redis = new Redis({
    host: '127.0.0.1',
    port: 6379,
    username: '',
    password: '',
    retryStrategy: function(times) {
        const delay = Math.min(times * 50, 2000);
        console.error(`Redis connection attempt ${times}, next retry in ${delay}ms`);
        return delay;
    },
    reconnectOnError: (err) => {
        console.error('Redis reconnection error:', err);
        return true;
    }
});

// Add error event listener
redis.on('error', (err) => {
    console.error('Redis Client Error:', err);
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
    console.log('New arcade client connected');
    
    ws.isAlive = true;
    ws.on('pong', () => { ws.isAlive = true; });

    // Handle incoming messages
    ws.on('message', async (message) => {
        try {
            const data = JSON.parse(message);
            
            switch(data.type) {
                case 'init_game':
                    await initializeArcadeGame(ws, data);
                    break;
                    
                case 'game_action':
                    await handleGameAction(ws, data);
                    break;
                    
                case 'end_game':
                    await handleEndGame(ws, data);
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
            handlePlayerDisconnect(ws);
            activeSessions.delete(ws.sessionId);
        }
        console.log('Arcade client disconnected');
    });
});

// Initialize arcade game session
async function initializeArcadeGame(ws, data) {
    try {
        // Verify user and game
        const [game] = await pool.execute(
            'SELECT * FROM games WHERE id = ? AND status = 1 AND category_id = 5', // category 5 is arcade
            [data.gameId]
        );

        if (game.length === 0) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid arcade game'
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
            score: 0,
            startTime: Date.now()
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

// Handle game action
async function handleGameAction(ws, data) {
    try {
        const session = activeSessions.get(ws.sessionId);
        if (!session) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid session'
            }));
        }

        // Process game-specific action
        switch(data.action) {
            case 'update_score':
                await updateScore(ws, data, session);
                break;
                
            case 'collect_bonus':
                await handleBonus(ws, data, session);
                break;
                
            default:
                ws.send(JSON.stringify({
                    type: 'error',
                    message: 'Unknown game action'
                }));
        }
    } catch (error) {
        console.error('Game action error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to process game action'
        }));
    }
}

// Update player score
async function updateScore(ws, data, session) {
    try {
        // Validate score update
        if (typeof data.score !== 'number' || data.score < session.score) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid score update'
            }));
        }

        session.score = data.score;
        
        // Update session in database
        await pool.execute(
            'UPDATE game_sessions SET score = ? WHERE id = ?',
            [session.score, ws.sessionId]
        );

        ws.send(JSON.stringify({
            type: 'score_updated',
            score: session.score
        }));
    } catch (error) {
        console.error('Score update error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to update score'
        }));
    }
}

// Handle bonus collection
async function handleBonus(ws, data, session) {
    try {
        // Calculate bonus based on score
        const bonus = calculateBonus(session.score);
        
        // Update user balance
        await pool.execute(
            'UPDATE users SET balance = balance + ? WHERE id = ?',
            [bonus, session.userId]
        );

        ws.send(JSON.stringify({
            type: 'bonus_collected',
            amount: bonus
        }));
    } catch (error) {
        console.error('Bonus collection error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to collect bonus'
        }));
    }
}

// Calculate bonus amount
function calculateBonus(score) {
    // This is a simplified example. In production, you would implement
    // proper bonus calculation logic based on game rules
    return Math.floor(score / 1000) * 10;
}

// Handle end game
async function handleEndGame(ws, data) {
    try {
        const session = activeSessions.get(ws.sessionId);
        if (!session) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid session'
            }));
        }

        // Calculate final score and duration
        const duration = Math.floor((Date.now() - session.startTime) / 1000);
        
        // Update session in database
        await pool.execute(
            'UPDATE game_sessions SET status = "completed", score = ?, duration = ? WHERE id = ?',
            [session.score, duration, ws.sessionId]
        );

        // Check for high score
        await updateHighScore(session);

        ws.send(JSON.stringify({
            type: 'game_ended',
            score: session.score,
            duration: duration
        }));

        activeSessions.delete(ws.sessionId);
    } catch (error) {
        console.error('End game error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to end game'
        }));
    }
}

// Update high score if applicable
async function updateHighScore(session) {
    try {
        const [currentHighScore] = await pool.execute(
            'SELECT score FROM high_scores WHERE game_id = ? ORDER BY score DESC LIMIT 1',
            [session.gameId]
        );

        if (!currentHighScore.length || session.score > currentHighScore[0].score) {
            await pool.execute(
                'INSERT INTO high_scores (user_id, game_id, score) VALUES (?, ?, ?)',
                [session.userId, session.gameId, session.score]
            );
        }
    } catch (error) {
        console.error('High score update error:', error);
    }
}

// Handle player disconnect
async function handlePlayerDisconnect(ws) {
    try {
        const session = activeSessions.get(ws.sessionId);
        if (session) {
            const duration = Math.floor((Date.now() - session.startTime) / 1000);
            
            // Update session in database
            await pool.execute(
                'UPDATE game_sessions SET status = "disconnected", score = ?, duration = ? WHERE id = ?',
                [session.score, duration, ws.sessionId]
            );
        }
    } catch (error) {
        console.error('Disconnect handling error:', error);
    }
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
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Arcade server is running on port ${PORT}`);
}); 