/**
 * Express.js REST API Server
 * Demonstrates intermediate multi-stage Docker builds with Node.js
 */

const express = require('express');
const morgan = require('morgan');
const helmet = require('helmet');
const compression = require('compression');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Security headers
app.use(compression()); // Response compression
app.use(morgan('combined')); // Request logging
app.use(express.json()); // JSON body parser
app.use(express.urlencoded({ extended: true })); // URL-encoded body parser

// Request counter for stats
let requestCount = 0;
const startTime = Date.now();

// Middleware to count requests
app.use((req, res, next) => {
  requestCount++;
  next();
});

// Routes

/**
 * Home route - API documentation
 */
app.get('/', (req, res) => {
  res.json({
    name: 'Express Multi-Stage Build API',
    version: '1.0.0',
    description: 'REST API demonstrating Node.js multi-stage Docker builds',
    endpoints: {
      'GET /': 'API documentation (this page)',
      'GET /api/health': 'Health check endpoint',
      'GET /api/info': 'System information',
      'GET /api/stats': 'Server statistics',
      'GET /api/hello': 'Simple greeting',
      'GET /api/hello/:name': 'Personalized greeting',
      'POST /api/echo': 'Echo back JSON payload',
      'GET /api/time': 'Current server time',
      'GET /api/env': 'Environment information'
    },
    features: [
      'Multi-stage Docker build',
      'Production dependencies only',
      'Security hardening with Helmet',
      'Response compression',
      'Request logging',
      'Health checks',
      'Non-root user execution'
    ]
  });
});

/**
 * Health check endpoint
 */
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'production',
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB',
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + 'MB'
    }
  });
});

/**
 * System information
 */
app.get('/api/info', (req, res) => {
  res.json({
    node_version: process.version,
    platform: process.platform,
    architecture: process.arch,
    environment: process.env.NODE_ENV || 'production',
    pid: process.pid,
    cwd: process.cwd(),
    memory: process.memoryUsage(),
    uptime: process.uptime()
  });
});

/**
 * Server statistics
 */
app.get('/api/stats', (req, res) => {
  const uptimeSeconds = Math.floor((Date.now() - startTime) / 1000);
  const uptimeFormatted = `${Math.floor(uptimeSeconds / 3600)}h ${Math.floor((uptimeSeconds % 3600) / 60)}m ${uptimeSeconds % 60}s`;
  
  res.json({
    requests: requestCount,
    uptime: uptimeFormatted,
    uptimeSeconds: uptimeSeconds,
    requestsPerSecond: (requestCount / uptimeSeconds).toFixed(2),
    startTime: new Date(startTime).toISOString()
  });
});

/**
 * Simple greeting
 */
app.get('/api/hello', (req, res) => {
  res.json({
    message: 'Hello from Express.js!',
    description: 'This is a multi-stage Docker build example',
    timestamp: new Date().toISOString()
  });
});

/**
 * Personalized greeting
 */
app.get('/api/hello/:name', (req, res) => {
  const { name } = req.params;
  res.json({
    message: `Hello, ${name}!`,
    personalized: true,
    from: 'Express Multi-Stage Build',
    timestamp: new Date().toISOString()
  });
});

/**
 * Echo endpoint - returns the POSTed JSON
 */
app.post('/api/echo', (req, res) => {
  res.json({
    echo: req.body,
    receivedAt: new Date().toISOString(),
    contentType: req.headers['content-type']
  });
});

/**
 * Current server time
 */
app.get('/api/time', (req, res) => {
  const now = new Date();
  res.json({
    iso: now.toISOString(),
    utc: now.toUTCString(),
    unix: Math.floor(now.getTime() / 1000),
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
  });
});

/**
 * Environment information
 */
app.get('/api/env', (req, res) => {
  res.json({
    nodeEnv: process.env.NODE_ENV || 'production',
    port: PORT,
    docker: process.env.DOCKER_CONTAINER === 'true' ? 'Yes' : 'No',
    stage: process.env.BUILD_STAGE || 'production',
    customEnvVars: {
      // Add any custom environment variables here
      example: process.env.EXAMPLE_VAR || 'not set'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
    timestamp: new Date().toISOString()
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: 'Internal Server Error',
    message: err.message || 'An unexpected error occurred',
    timestamp: new Date().toISOString()
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 Express Multi-Stage Build Server');
  console.log('=====================================');
  console.log(`📡 Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`📦 Node version: ${process.version}`);
  console.log(`🔧 Platform: ${process.platform} (${process.arch})`);
  console.log(`💾 Memory: ${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB used`);
  console.log(`🐳 Docker: ${process.env.DOCKER_CONTAINER === 'true' ? 'Yes' : 'No'}`);
  console.log('=====================================');
  console.log(`📝 API Docs: http://localhost:${PORT}/`);
  console.log(`❤️  Health Check: http://localhost:${PORT}/api/health`);
  console.log('');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\nSIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;
