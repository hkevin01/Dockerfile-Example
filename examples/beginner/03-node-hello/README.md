# Node.js Hello World Docker Example

This example demonstrates how to containerize a Node.js application using Docker with best practices for security, performance, and maintainability.

## 📋 What You'll Learn

- **Node.js Containerization**: How to package a Node.js application in Docker
- **Security Best Practices**: Non-root user, minimal dependencies, health checks
- **Layer Optimization**: Proper layer caching with package.json copying
- **Express.js Framework**: Building a simple web server
- **Health Monitoring**: Container health checks and graceful shutdown
- **Multi-endpoint API**: RESTful endpoints with proper error handling

## 🏗️ Project Structure

```
03-node-hello/
├── Dockerfile          # Container definition with security best practices
├── package.json         # Node.js project configuration
├── app.js              # Main Express.js application
├── healthcheck.js      # Health check script for Docker
└── README.md           # This documentation
```

## 🔧 Key Docker Concepts

### 1. **Base Image Selection**
```dockerfile
FROM node:18-alpine
```
- Uses Node.js 18 LTS Alpine for minimal size and security
- Alpine Linux reduces attack surface and image size

### 2. **Security Hardening**
```dockerfile
RUN addgroup -g 1001 -S nodegroup && \
    adduser -S nodeuser -u 1001 -G nodegroup
USER nodeuser
```
- Creates and uses non-root user for enhanced security
- Follows principle of least privilege

### 3. **Layer Optimization**
```dockerfile
COPY package*.json ./
RUN npm ci --only=production --silent
COPY . .
```
- Copies package files first for better Docker layer caching
- Uses `npm ci` for reproducible builds

### 4. **Health Monitoring**
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1
```
- Implements container health checks
- Enables Docker to monitor application health

## 🚀 How to Build and Run

### Step 1: Build the Docker Image
```bash
docker build -t node-hello-app .
```

### Step 2: Run the Container
```bash
docker run -d -p 3000:3000 --name node-hello node-hello-app
```

### Step 3: Test the Application
```bash
# Main endpoint
curl http://localhost:3000

# Health check
curl http://localhost:3000/health

# Application info
curl http://localhost:3000/info
```

### Step 4: View Logs
```bash
docker logs node-hello
```

### Step 5: Clean Up
```bash
docker stop node-hello
docker rm node-hello
```

## 📡 API Endpoints

| Endpoint | Description | Response |
|----------|-------------|----------|
| `GET /` | Main application endpoint | System info and greeting |
| `GET /health` | Health check endpoint | Application health status |
| `GET /info` | Application information | Detailed app and system info |

## 🔍 Example Responses

### Root Endpoint (`/`)
```json
{
  "message": "Hello from Node.js in Docker! 🐳",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "container": {
    "hostname": "abc123def456",
    "platform": "linux",
    "architecture": "x64",
    "nodeVersion": "v18.19.0",
    "uptime": 123.45
  },
  "environment": "production",
  "pid": 1
}
```

### Health Endpoint (`/health`)
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 123.45
}
```

## 🛡️ Security Features

1. **Non-root User**: Application runs as `nodeuser` (UID 1001)
2. **Minimal Dependencies**: Only production dependencies installed
3. **Health Checks**: Container health monitoring enabled
4. **Graceful Shutdown**: Proper signal handling for clean termination
5. **Error Handling**: Comprehensive error handling and logging

## 🎯 Best Practices Demonstrated

- **Layer Caching**: Package files copied before application code
- **Security**: Non-root user execution
- **Health Monitoring**: Built-in health check endpoint
- **Clean Architecture**: Separation of concerns with dedicated health check script
- **Environment Awareness**: Environment variable usage
- **Graceful Shutdown**: Proper signal handling
- **Comprehensive Logging**: Detailed startup and error logging

## 🔧 Development Tips

### View Container Details
```bash
# Inspect the running container
docker inspect node-hello

# Check health status
docker inspect --format='{{.State.Health.Status}}' node-hello

# View container processes
docker exec node-hello ps aux
```

### Debug Container Issues
```bash
# Interactive shell access
docker exec -it node-hello sh

# Check Node.js version
docker exec node-hello node --version

# View environment variables
docker exec node-hello env
```

### Performance Monitoring
```bash
# Container resource usage
docker stats node-hello

# Container logs with timestamps
docker logs -t node-hello
```

## 📚 Learning Exercises

1. **Modify the Port**: Change the application to run on port 8080
2. **Add Environment Variables**: Configure the greeting message via environment variable
3. **Volume Mounting**: Mount a local directory for configuration files
4. **Multi-stage Build**: Optimize the Dockerfile with multi-stage build
5. **Custom Health Check**: Modify the health check to test database connectivity

## 🔗 Next Steps

- Explore `04-static-website` for Nginx-based static content serving
- Learn about environment variables in `07-environment-vars`
- Study Express.js framework patterns in `06-node-express`

## 📖 Additional Resources

- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)
- [Express.js Documentation](https://expressjs.com/)
- [Docker Health Check Reference](https://docs.docker.com/engine/reference/builder/#healthcheck)
- [Alpine Linux Security](https://wiki.alpinelinux.org/wiki/Alpine_Linux:Security)
