const WebSocket = require('ws');
const fs = require('fs');
const https = require('https');
const Redis = require('ioredis');
const mysql = require('mysql2/promise');
const path = require('path');

// Load configurations
const config = require('./socket_config.json');

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

// WebSocket connection handler
wss.on('connection', async (ws, req) => {
    console.log('New client connected');
    
    ws.isAlive = true;
    ws.on('pong', () => { ws.isAlive = true; });

    // Handle incoming messages
    ws.on('message', async (message) => {
        try {
            const data = JSON.parse(message);
            
            // Handle different message types
            switch(data.type) {
                case 'auth':
                    // Authenticate user
                    handleAuth(ws, data);
                    break;
                    
                case 'game_action':
                    // Handle game actions
                    handleGameAction(ws, data);
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
        console.log('Client disconnected');
    });
});

// Connection health check
const interval = setInterval(() => {
    wss.clients.forEach((ws) => {
        if (ws.isAlive === false) return ws.terminate();
        ws.isAlive = false;
        ws.ping(() => {});
    });
}, 30000);

// Handle authentication
async function handleAuth(ws, data) {
    try {
        // Verify user credentials from database
        const [rows] = await pool.execute(
            'SELECT id, username FROM users WHERE id = ? AND status = 1',
            [data.userId]
        );

        if (rows.length > 0) {
            ws.userId = rows[0].id;
            ws.send(JSON.stringify({
                type: 'auth_success',
                userId: rows[0].id,
                username: rows[0].username
            }));
        } else {
            ws.send(JSON.stringify({
                type: 'auth_failed',
                message: 'Invalid credentials'
            }));
        }
    } catch (error) {
        console.error('Auth error:', error);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Authentication failed'
        }));
    }
}

// Handle game actions
async function handleGameAction(ws, data) {
    try {
        // Verify game session
        const [session] = await pool.execute(
            'SELECT * FROM game_sessions WHERE id = ? AND user_id = ? AND status = "active"',
            [data.sessionId, ws.userId]
        );

        if (session.length === 0) {
            return ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid game session'
            }));
        }

        // Process game action based on type
        switch(data.action) {
            case 'bet':
                handleBet(ws, data, session[0]);
                break;
            
            case 'spin':
                handleSpin(ws, data, session[0]);
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

// Start the server
const PORT = process.env.PORT || config.port;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
}); 