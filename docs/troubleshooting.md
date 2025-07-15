# Troubleshooting Guide

Common issues and solutions when working with Docker examples in this repository.

## 🐳 Docker Installation Issues

### Docker Not Starting
**Problem**: Docker daemon not running
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solutions**:
```bash
# On Linux
sudo systemctl start docker
sudo systemctl enable docker

# On macOS/Windows
# Start Docker Desktop application

# Check Docker status
docker --version
docker info
```

### Permission Denied
**Problem**: Permission denied when running Docker commands
```
permission denied while trying to connect to the Docker daemon socket
```

**Solution**:
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Log out and log back in

# Or use sudo for individual commands
sudo docker build -t example .
```

## 🏗️ Build Issues

### Build Context Too Large
**Problem**: Build takes too long or fails due to large context
```
Sending build context to Docker daemon  2.5GB
```

**Solutions**:
```bash
# Create/update .dockerignore file
echo "node_modules" >> .dockerignore
echo "*.log" >> .dockerignore
echo ".git" >> .dockerignore

# Check context size
docker build --no-cache --progress=plain .
```

### Package Installation Failures
**Problem**: Package manager fails during build
```
E: Unable to locate package
```

**Solutions**:
```dockerfile
# Update package lists first
RUN apt-get update && apt-get install -y package-name

# For Alpine Linux
RUN apk update && apk add package-name

# Clear cache in same layer
RUN apt-get update && apt-get install -y package-name \
    && rm -rf /var/lib/apt/lists/*
```

### Network Issues During Build
**Problem**: Cannot download packages or dependencies
```
Could not resolve host
```

**Solutions**:
```bash
# Check host network connectivity
ping google.com

# Use different DNS in Docker
docker build --build-arg http_proxy=http://proxy:port .

# Configure Docker daemon DNS
# Edit /etc/docker/daemon.json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

## 🚀 Runtime Issues

### Port Binding Failures
**Problem**: Port already in use
```
Error: bind: address already in use
```

**Solutions**:
```bash
# Check what's using the port
sudo netstat -tulpn | grep :8080
lsof -i :8080

# Use different port
docker run -p 8081:8080 your-image

# Stop conflicting container
docker stop $(docker ps -q --filter "publish=8080")
```

### Container Exits Immediately
**Problem**: Container starts and exits immediately
```
Container exited with code 0
```

**Solutions**:
```bash
# Check container logs
docker logs container-name

# Run interactively for debugging
docker run -it your-image /bin/bash

# Add proper CMD or ENTRYPOINT
# In Dockerfile:
CMD ["your-command", "arg1", "arg2"]
```

### Out of Memory Issues
**Problem**: Container killed due to memory limits
```
Killed
```

**Solutions**:
```bash
# Increase memory limit
docker run -m 512m your-image

# Check memory usage
docker stats container-name

# Optimize application memory usage
# Monitor with tools like htop inside container
```

## 🔗 Networking Issues

### Service Discovery Problems
**Problem**: Services can't communicate in Docker Compose
```
Name or service not known
```

**Solutions**:
```yaml
# Use service names in docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - db
  db:
    image: postgres:13
    
# Connect using service name: http://db:5432
```

### External Network Access
**Problem**: Container cannot access external services
```
Network is unreachable
```

**Solutions**:
```bash
# Check Docker network settings
docker network ls
docker network inspect bridge

# Use host networking (Linux only)
docker run --network host your-image

# Configure custom network
docker network create custom-network
docker run --network custom-network your-image
```

## 💾 Volume and Storage Issues

### Permission Denied on Volumes
**Problem**: Cannot write to mounted volume
```
Permission denied
```

**Solutions**:
```bash
# Check file ownership
ls -la /host/path

# Fix ownership
sudo chown -R $USER:$USER /host/path

# Use proper user in container
# In Dockerfile:
USER 1000:1000
```

### Volume Not Persisting Data
**Problem**: Data lost when container restarts
```
Data not persisting between runs
```

**Solutions**:
```bash
# Use named volumes
docker volume create mydata
docker run -v mydata:/app/data your-image

# Use bind mounts with absolute paths
docker run -v /host/absolute/path:/container/path your-image

# Check volume configuration
docker volume inspect mydata
```

## 🔒 Security Issues

### Vulnerability Warnings
**Problem**: Security scanner reports vulnerabilities
```
High severity vulnerabilities found
```

**Solutions**:
```bash
# Update base image
FROM node:18-alpine  # Instead of older versions

# Scan images regularly
docker scan your-image

# Use distroless images
FROM gcr.io/distroless/node:18

# Keep dependencies updated
RUN npm audit fix
```

### Root User Warnings
**Problem**: Running as root user
```
WARNING: Running as root user
```

**Solutions**:
```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Or use existing user
USER node  # For Node.js official images
```

## 🔧 Development Issues

### Hot Reload Not Working
**Problem**: Code changes not reflected in development
```
Changes not appearing in running container
```

**Solutions**:
```yaml
# Use bind mounts for development
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
      - /app/node_modules  # Exclude node_modules
    environment:
      - NODE_ENV=development
```

### Debugging Inside Container
**Problem**: Need to inspect running container
```
Need to check what's happening inside
```

**Solutions**:
```bash
# Execute shell in running container
docker exec -it container-name /bin/bash
docker exec -it container-name /bin/sh  # For Alpine

# Check container processes
docker exec container-name ps aux

# Check files and logs
docker exec container-name ls -la /app
docker exec container-name cat /var/log/app.log
```

## 🌐 Specific Technology Issues

### Python Issues
```bash
# Module not found
pip install --no-cache-dir -r requirements.txt

# Python path issues
ENV PYTHONPATH=/app

# Use specific Python version
FROM python:3.9-slim
```

### Node.js Issues
```bash
# NPM permission issues
RUN npm config set unsafe-perm true

# Clear npm cache
RUN npm cache clean --force

# Use npm ci for production
RUN npm ci --only=production
```

### Database Connection Issues
```yaml
# Wait for database to be ready
services:
  app:
    depends_on:
      db:
        condition: service_healthy
  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5
```

## 📊 Monitoring and Logging

### No Logs Visible
**Problem**: Cannot see application logs
```
No output from docker logs
```

**Solutions**:
```dockerfile
# Ensure app logs to stdout/stderr
# Not to files inside container

# For Python
import logging
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

# For Node.js
console.log("Use console.log for stdout")
```

### High Resource Usage
**Problem**: Container using too much CPU/memory
```
Performance issues
```

**Solutions**:
```bash
# Monitor resource usage
docker stats

# Set resource limits
docker run --cpus="1.0" --memory="512m" your-image

# Profile application
# Add profiling tools to your application
```

## 🆘 Getting Help

When reporting issues, please include:

1. **Environment information**:
   ```bash
   docker --version
   docker-compose --version
   uname -a
   ```

2. **Error messages** (full output)
3. **Steps to reproduce**
4. **Expected vs actual behavior**
5. **Relevant configuration files**

### Useful Debugging Commands
```bash
# Container information
docker inspect container-name

# Image layers
docker history image-name

# System information
docker system info
docker system df

# Clean up resources
docker system prune
docker volume prune
docker network prune
```

---

If you don't find your issue here, please check the [GitHub Issues](https://github.com/hkevin01/Dockerfile-Example/issues) or create a new issue with detailed information.
