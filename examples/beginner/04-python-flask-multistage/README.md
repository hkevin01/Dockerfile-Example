# Python Flask Multi-Stage Build Example

## 🎯 Overview

This example demonstrates a **multi-stage Docker build** for a Python Flask web application. Multi-stage builds are a powerful Docker feature that creates smaller, more secure, and more efficient container images by separating the build environment from the runtime environment.

## 📚 What You'll Learn

- ✅ Understanding multi-stage Docker builds
- ✅ Separating build dependencies from runtime dependencies
- ✅ Reducing final image size
- ✅ Improving container security
- ✅ Using Python virtual environments in containers
- ✅ Running Flask with Gunicorn for production
- ✅ Implementing health checks
- ✅ Following security best practices (non-root user)

## 🏗️ Multi-Stage Build Architecture

```
┌─────────────────────────────────────┐
│      Stage 1: Builder               │
│  ┌───────────────────────────────┐  │
│  │ Base: python:3.11-slim        │  │
│  │ Install: gcc, python3-dev     │  │
│  │ Create: virtual environment   │  │
│  │ Install: pip dependencies     │  │
│  │ Copy: application code        │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
                  │
                  │ COPY --from=builder
                  ▼
┌─────────────────────────────────────┐
│    Stage 2: Production Runtime      │
│  ┌───────────────────────────────┐  │
│  │ Base: python:3.11-slim        │  │
│  │ Copy: /opt/venv (from stage 1)│  │
│  │ Copy: app.py (from stage 1)   │  │
│  │ Setup: non-root user          │  │
│  │ Run: gunicorn server          │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
           Final Image
         (Smaller & Secure)
```

## 📁 Project Structure

```
04-python-flask-multistage/
├── app.py              # Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile          # Multi-stage build configuration
├── compare.sh          # Script to compare image sizes
└── README.md           # This file
```

## 🔧 Technologies Used

### Flask (Web Framework)
- **Version**: 3.0.0
- **Purpose**: Lightweight Python web framework
- **Why**: Easy to learn, perfect for demonstrating containerization

### Gunicorn (WSGI Server)
- **Version**: 21.2.0
- **Purpose**: Production-grade WSGI HTTP server
- **Why**: More robust than Flask's built-in server for production

### Docker Multi-Stage Builds
- **Purpose**: Optimize image size and security
- **Why**: Industry best practice for production containers

## 📖 How Multi-Stage Builds Work

### Stage 1: Builder
```dockerfile
FROM python:3.11-slim AS builder
```

This stage:
1. Installs build tools (gcc, python3-dev)
2. Creates a Python virtual environment
3. Installs all Python dependencies
4. Copies application code

**Size**: ~300-400MB (includes build tools)

### Stage 2: Production
```dockerfile
FROM python:3.11-slim AS production
```

This stage:
1. Starts with a fresh, clean Python image
2. Copies ONLY the virtual environment from Stage 1
3. Copies ONLY the application code
4. Excludes all build tools and temporary files

**Size**: ~150-200MB (50%+ smaller!)

## 🚀 Quick Start

### Prerequisites
- Docker installed (version 24.0+)
- Basic understanding of Docker commands

### Build the Image

```bash
docker build -t flask-multistage .
```

### Run the Container

```bash
docker run -p 5000:5000 flask-multistage
```

### Test the Application

Open your browser and visit:
- **Home Page**: http://localhost:5000
- **Health Check**: http://localhost:5000/api/health
- **System Info**: http://localhost:5000/api/info
- **Hello API**: http://localhost:5000/api/hello
- **Personalized Hello**: http://localhost:5000/api/hello/YourName

Or use curl:
```bash
# Health check
curl http://localhost:5000/api/health

# Get system info
curl http://localhost:5000/api/info

# Simple greeting
curl http://localhost:5000/api/hello

# Personalized greeting
curl http://localhost:5000/api/hello/Docker
```

## 📊 Compare Single-Stage vs Multi-Stage

Run the comparison script to see the difference:

```bash
./compare.sh
```

This script will:
1. Build both single-stage and multi-stage images
2. Compare their sizes
3. Show layer differences
4. Display space savings

**Expected Results**:
- Single-stage image: ~300-400MB
- Multi-stage image: ~150-200MB
- **Savings: 50%+ reduction in size!**

## 🔍 Understanding the Dockerfile

### Key Techniques

#### 1. Named Build Stages
```dockerfile
FROM python:3.11-slim AS builder    # Stage 1
FROM python:3.11-slim AS production # Stage 2
```

#### 2. Copying from Previous Stages
```dockerfile
COPY --from=builder /opt/venv /opt/venv
```

#### 3. Virtual Environment Benefits
- Isolates dependencies
- Easy to copy between stages
- Clean separation from system Python

#### 4. Security Best Practices
```dockerfile
RUN addgroup --gid 1001 --system appgroup && \
    adduser --uid 1001 --system --group appgroup
USER appgroup
```

#### 5. Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s \
    CMD python -c "import urllib.request; ..."
```

## 🎓 Learning Objectives Achieved

### Beginner Level
- ✅ Understand what multi-stage builds are
- ✅ See practical benefits (size reduction)
- ✅ Learn basic Docker optimization

### Intermediate Level
- ✅ Implement virtual environments in Docker
- ✅ Separate build and runtime concerns
- ✅ Use production-grade WSGI server

### Advanced Concepts Introduced
- ✅ Build caching strategies
- ✅ Layer optimization
- ✅ Security hardening

## 💡 Benefits of Multi-Stage Builds

### 1. Smaller Images
- Excludes build tools from final image
- Reduces download and deployment time
- Saves registry storage space

### 2. Enhanced Security
- Smaller attack surface
- No unnecessary tools in production
- Minimal dependencies

### 3. Faster Deployments
- Smaller images transfer faster
- Quicker container startup
- More efficient CI/CD pipelines

### 4. Better Caching
- Build stage cached separately
- Runtime stage cached separately
- Faster rebuilds during development

### 5. Cleaner Separation
- Build concerns separated from runtime
- Easier to understand and maintain
- More modular and reusable

## 🔧 Common Commands

### Build Specific Stage
```bash
# Build only the builder stage (for testing)
docker build --target builder -t flask-builder .

# Build the production stage (default)
docker build -t flask-multistage .
```

### Inspect Image Layers
```bash
docker history flask-multistage:latest
```

### Check Image Size
```bash
docker images flask-multistage
```

### Run with Environment Variables
```bash
docker run -p 5000:5000 \
  -e PORT=5000 \
  -e FLASK_ENV=production \
  flask-multistage
```

### Run in Background
```bash
docker run -d -p 5000:5000 --name flask-app flask-multistage
```

### View Logs
```bash
docker logs flask-app
```

### Stop and Remove
```bash
docker stop flask-app
docker rm flask-app
```

## 🧪 Testing

### Manual Testing
1. Build the image
2. Run the container
3. Visit http://localhost:5000
4. Test all API endpoints
5. Check health endpoint

### Automated Testing
```bash
# Build
docker build -t flask-multistage .

# Run in background
docker run -d -p 5000:5000 --name test-flask flask-multistage

# Wait for startup
sleep 5

# Test health endpoint
curl -f http://localhost:5000/api/health || exit 1

# Test info endpoint
curl -f http://localhost:5000/api/info || exit 1

# Cleanup
docker stop test-flask
docker rm test-flask
```

## 📈 Image Size Comparison

| <sub>Build Type</sub> | <sub>Image Size</sub> | <sub>Build Tools</sub> | <sub>Security</sub> | <sub>Production Ready</sub> |
|-----------|-----------|-------------|----------|-----------------|
| <sub>Single-Stage</sub> | <sub>~350MB</sub> | <sub>Included ❌</sub> | <sub>Lower</sub> | <sub>No</sub> |
| <sub>Multi-Stage</sub> | <sub>~175MB</sub> | <sub>Excluded ✅</sub> | <sub>Higher</sub> | <sub>Yes</sub> |
| <sub>**Savings**</sub> | <sub>**50%**</sub> | <sub>**✓**</sub> | <sub>**✓**</sub> | <sub>**✓**</sub> |

## 🔐 Security Features

1. **Non-root User**: Application runs as user `appgroup` (UID 1001)
2. **Minimal Base Image**: Uses slim variant, not full Python image
3. **No Build Tools**: gcc, make, etc. excluded from final image
4. **Security Updates**: Based on official Python images with patches
5. **Health Checks**: Automatic container health monitoring

## 🐛 Troubleshooting

### Build Fails in Builder Stage
```bash
# Check if Docker has internet access
docker run --rm alpine ping -c 1 google.com

# Clean build cache
docker builder prune
```

### Container Won't Start
```bash
# Check logs
docker logs <container-name>

# Run with interactive shell
docker run -it flask-multistage /bin/bash
```

### Port Already in Use
```bash
# Use a different port
docker run -p 5001:5000 flask-multistage
```

### Health Check Failing
```bash
# Check if app is running
docker exec <container-name> curl http://localhost:5000/api/health

# Increase health check start period
# Edit Dockerfile HEALTHCHECK --start-period value
```

## 📚 Next Steps

After mastering this example, try:

1. **Intermediate**: Node.js Express multi-stage build
2. **Advanced**: Go microservice with scratch-based image
3. **Expert**: Full-stack React + Node.js multi-stage build

## 🔗 Additional Resources

- [Docker Multi-Stage Builds Documentation](https://docs.docker.com/build/building/multi-stage/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Gunicorn Documentation](https://docs.gunicorn.org/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📄 License

This example is part of the Dockerfile Examples Project and is licensed under the MIT License.

---

**🎉 Congratulations!** You now understand multi-stage Docker builds and can apply this pattern to your own projects!