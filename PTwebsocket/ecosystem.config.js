module.exports = {
  apps: [{
    name: 'casino-slots',
    script: './PTwebsocket/Slots.js',
    watch: false,
    env: {
      NODE_ENV: 'production',
      PORT: 22154
    },
    instances: 2,
    exec_mode: 'cluster',
    max_memory_restart: '1G'
  }, {
    name: 'casino-arcade',
    script: './PTwebsocket/Arcade.js',
    watch: false,
    env: {
      NODE_ENV: 'production',
      PORT: 22197
    },
    instances: 2,
    exec_mode: 'cluster',
    max_memory_restart: '1G'
  }, {
    name: 'casino-server',
    script: './PTwebsocket/Server.js',
    watch: false,
    env: {
      NODE_ENV: 'production'
    },
    instances: 2,
    exec_mode: 'cluster',
    max_memory_restart: '1G'
  }]
}; 