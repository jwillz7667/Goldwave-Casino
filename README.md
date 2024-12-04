# Goldwave Casino WebSocket Servers

## Project Overview
This project contains WebSocket servers for the Goldwave Casino platform, handling real-time game interactions, authentication, and game sessions.

## Components
- `Server.js`: Main WebSocket server for general casino operations
- `Arcade.js`: WebSocket server for arcade game interactions
- `Slots.js`: WebSocket server for slot machine game interactions

## Prerequisites
- Node.js (v18.x or later)
- Redis
- MySQL
- PM2 Process Manager

## Installation
1. Clone the repository
2. Install dependencies:
   ```
   cd PTwebsocket
   npm install
   ```

## Configuration
- Configure `.env` file with your specific settings
- Update `socket_config.json` and `arcade_config.json` as needed

## Running the Application
- Start with PM2:
  ```
  npm run start
  ```
- Stop with PM2:
  ```
  npm run stop
  ```

## Development
- Use `npm run restart` to restart all services
- Check logs with `npm run logs`

## Security Notes
- SSL certificates are required
- Ensure proper Redis and MySQL configurations
- Use environment-specific configurations

## Deployment
- Use PM2 for process management
- Configure nginx for reverse proxy
- Set up proper SSL termination

## Troubleshooting
- Check Redis connection
- Verify MySQL database settings
- Review PM2 logs for any startup issues

## License
Proprietary - Goldwave Casino
