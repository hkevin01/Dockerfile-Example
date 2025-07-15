const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware for JSON parsing
app.use(express.json());

// Root endpoint
app.get('/', (req, res) => {
  const response = {
    message: 'Hello from Node.js in Docker! 🐳',
    timestamp: new Date().toISOString(),
    container: {
      hostname: os.hostname(),
      platform: os.platform(),
      architecture: os.arch(),
      nodeVersion: process.version,
      uptime: process.uptime()
    },
    environment: process.env.NODE_ENV || 'development',
    pid: process.pid
  };
  
  res.json(response);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Info endpoint
app.get('/info', (req, res) => {
  res.json({
    application: 'Node.js Hello World',
    version: '1.0.0',
    description: 'A simple Node.js application demonstrating containerization',
    endpoints: {
      '/': 'Main application endpoint',
      '/health': 'Health check endpoint',
      '/info': 'Application information'
    },
    system: {
      nodeVersion: process.version,
      platform: os.platform(),
      hostname: os.hostname(),
      totalMemory: `${Math.round(os.totalmem() / 1024 / 1024)} MB`,
      freeMemory: `${Math.round(os.freemem() / 1024 / 1024)} MB`,
      loadAverage: os.loadavg()
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  res.status(500).json({
    error: 'Internal Server Error',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `The requested endpoint ${req.originalUrl} was not found`,
    timestamp: new Date().toISOString()
  });
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Node.js Hello World app listening on port ${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🏠 Hostname: ${os.hostname()}`);
  console.log(`📊 Platform: ${os.platform()} ${os.arch()}`);
  console.log(`🟢 Application started successfully at ${new Date().toISOString()}`);
});

module.exports = app;
