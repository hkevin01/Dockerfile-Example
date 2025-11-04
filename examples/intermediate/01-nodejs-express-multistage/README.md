# Node.js Express Multi-Stage Build Example

## 🎯 Overview

Intermediate-level example demonstrating **multi-stage Docker builds** for a Node.js Express REST API with separate development and production stages.

## 🏗️ Multi-Stage Architecture

This Dockerfile uses **4 stages**:

1. **Dependencies**: Installs all dependencies (including dev)
2. **Builder**: Installs production dependencies only
3. **Production**: Minimal runtime image (~120MB)
4. **Development**: Development environment with hot-reload

## 🚀 Quick Start

### Production Build
```bash
docker build -t express-multistage .
docker run -p 3000:3000 express-multistage
```

### Development Build
```bash
docker build --target development -t express-dev .
docker run -p 3000:3000 -v $(pwd)/server.js:/app/server.js:ro express-dev
```

### Using Docker Compose
```bash
# Production
docker-compose up app

# Development (with hot-reload)
docker-compose --profile dev up app-dev
```

## 📊 Image Size Comparison

| Stage | Size | Use Case |
|-------|------|----------|
| Production | ~120MB | Deployment |
| Development | ~180MB | Local development |
| Single-stage | ~300MB+ | Not recommended |

## 🔑 Key Features

- ✅ Separate production & development stages
- ✅ Production image excludes devDependencies
- ✅ Hot-reload in development mode
- ✅ Security hardening (helmet, non-root user)
- ✅ Proper signal handling (dumb-init)
- ✅ Health checks
- ✅ Response compression
- ✅ Request logging

## 📚 API Endpoints

- `GET /` - API documentation
- `GET /api/health` - Health check
- `GET /api/info` - System information
- `GET /api/stats` - Server statistics
- `GET /api/hello` - Simple greeting
- `GET /api/hello/:name` - Personalized greeting
- `POST /api/echo` - Echo JSON payload
- `GET /api/time` - Current server time
- `GET /api/env` - Environment info

## 🔧 Technologies

- **Express.js 4.18**: Web framework
- **Helmet**: Security headers
- **Morgan**: Request logging
- **Compression**: Response compression
- **Nodemon**: Development hot-reload
- **dumb-init**: Signal handling

## 📖 What You'll Learn

- Multi-stage builds with multiple targets
- Separating production vs. development dependencies
- Using Docker Compose with profiles
- Signal handling in Node.js containers
- Health check implementation
- Volume mounting for hot-reload

## 🔐 Security Features

1. Non-root user (nodejs:1001)
2. Helmet security headers
3. Minimal Alpine-based image
4. No devDependencies in production
5. Proper signal handling

## 📄 License

MIT License - Part of Dockerfile Examples Project
