# Example Name Template

Brief description of what this Docker example demonstrates and its learning objectives.

## 🎯 What You'll Learn

- Concept 1 (e.g., Multi-stage builds)
- Concept 2 (e.g., Environment variables)
- Concept 3 (e.g., Health checks)
- Technology-specific concepts

## 📋 Prerequisites

- Docker installed and running
- Basic understanding of [relevant technology]
- Familiarity with [previous examples if applicable]

## 🚀 Quick Start

### Option 1: Docker Build and Run

1. **Build the image**:
   ```bash
   docker build -t example-name .
   ```

2. **Run the container**:
   ```bash
   docker run -p PORT:PORT example-name
   ```

### Option 2: Docker Compose (if applicable)

1. **Start services**:
   ```bash
   docker-compose up -d
   ```

2. **Check status**:
   ```bash
   docker-compose ps
   docker-compose logs
   ```

## 📖 Dockerfile Explanation

### Base Image Selection
```dockerfile
FROM base:tag
```
Explain why this base image was chosen and its benefits.

### Key Instructions
```dockerfile
RUN some-command
COPY source dest
ENV VARIABLE=value
```
Explain each important instruction and its purpose.

### Multi-stage Build (if applicable)
```dockerfile
FROM base AS builder
# Build stage

FROM runtime
# Runtime stage
```
Explain the multi-stage approach and optimization benefits.

## 🧪 Testing the Example

### Functionality Tests
```bash
# Test command 1
curl http://localhost:PORT/endpoint

# Test command 2
docker exec container-name command
```

### Health Check
```bash
# Check container health
docker ps
docker logs container-name
```

## 🔍 Exploring the Container

### Interactive Mode
```bash
# Access container shell
docker exec -it container-name /bin/bash

# Explore file system
ls -la /app
cat /etc/config-file
```

### Monitoring
```bash
# Resource usage
docker stats container-name

# Process list
docker exec container-name ps aux
```

## ⚙️ Configuration Options

### Environment Variables
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `VAR1` | Description of variable | `default_value` | `custom_value` |
| `VAR2` | Another variable | `default` | `example` |

### Volume Mounts
| Path | Description | Type |
|------|-------------|------|
| `/app/data` | Application data | Volume |
| `/app/config` | Configuration files | Bind mount |

### Port Mappings
| Container Port | Description | Protocol |
|----------------|-------------|----------|
| `8080` | Web interface | HTTP |
| `9090` | Metrics endpoint | HTTP |

## 🛠️ Development Mode

### Hot Reloading (if applicable)
```yaml
# docker-compose.dev.yml
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

### Debugging
```bash
# Debug mode
docker run -it --entrypoint /bin/bash example-name

# With debugger port
docker run -p 9229:9229 example-name
```

## 🔒 Security Considerations

### Production Hardening
- Use non-root user
- Scan for vulnerabilities
- Implement proper secrets management
- Set resource limits

### Example Security Improvements
```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S appgroup
RUN adduser -S appuser -u 1001
USER appuser

# Set resource limits
# In docker-compose.yml
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '0.5'
```

## 📊 Performance Optimization

### Image Size
- Current image size: ~XXX MB
- Optimization techniques used:
  - Multi-stage builds
  - Alpine base image
  - Layer optimization

### Runtime Performance
- Memory usage: ~XXX MB
- CPU usage: ~X%
- Startup time: ~X seconds

## 🔗 Integration Examples

### With Other Services
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    depends_on:
      - database
      - cache
  
  database:
    image: postgres:13
    
  cache:
    image: redis:6-alpine
```

### API Usage (if applicable)
```bash
# Example API calls
curl -X GET http://localhost:PORT/api/endpoint
curl -X POST http://localhost:PORT/api/data -d '{"key": "value"}'
```

## 🎓 Key Concepts Learned

1. **Concept 1**: Detailed explanation of what was learned
2. **Concept 2**: Another key learning point
3. **Best Practice**: Important Docker best practice demonstrated
4. **Technology Insight**: Specific technology knowledge gained

## 🔗 Next Steps

After mastering this example, try:
- [Next Example](../next-example/) - Brief description
- [Related Example](../related-example/) - Brief description
- [Advanced Version](../../advanced/advanced-version/) - Brief description

## 🐛 Troubleshooting

### Common Issues

#### Issue 1: Container Won't Start
**Problem**: Container exits immediately
```
Error message example
```

**Solution**:
```bash
# Check logs
docker logs container-name

# Debug interactively
docker run -it --entrypoint /bin/bash example-name
```

#### Issue 2: Port Already in Use
**Problem**: Cannot bind to port
```
Error: port already in use
```

**Solution**:
```bash
# Find what's using the port
sudo netstat -tulpn | grep :PORT

# Use different port
docker run -p 8081:8080 example-name
```

#### Issue 3: Permission Denied
**Problem**: File permission issues
```
Permission denied error
```

**Solution**:
```bash
# Fix file ownership
sudo chown -R $USER:$USER /path/to/files

# Or run with proper user
docker run --user $(id -u):$(id -g) example-name
```

### Getting Help
If you encounter issues not covered here:
1. Check the [main troubleshooting guide](../../docs/troubleshooting.md)
2. Search existing [GitHub issues](https://github.com/hkevin01/Dockerfile-Example/issues)
3. Create a new issue with detailed information

---

**Difficulty**: Beginner/Intermediate/Advanced/Expert
**Estimated Time**: X minutes
**Technologies**: List of technologies used
**Related Examples**: Links to related examples
