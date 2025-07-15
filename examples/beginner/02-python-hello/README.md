# Python Hello World Docker Example

A containerized Python application demonstrating basic Python containerization concepts, dependency management, and Docker best practices for Python development.

## 🎯 What You'll Learn

- Python application containerization basics
- Python dependency management with requirements.txt
- Environment variable handling in Python containers
- User permissions and security in Python containers
- Python-specific Docker optimizations
- Interactive vs non-interactive container execution

## 📋 Prerequisites

- Docker installed and running
- Basic Python knowledge
- Understanding of the [01-hello-world](../01-hello-world/) example

## 🚀 Quick Start

### Option 1: Docker Build and Run

1. **Build the image**:
   ```bash
   docker build -t python-hello .
   ```

2. **Run the container**:
   ```bash
   docker run --rm python-hello
   ```

3. **Run interactively**:
   ```bash
   docker run -it --rm python-hello
   ```

### Option 2: With Custom Arguments

```bash
# Pass arguments to the Python script
docker run --rm python-hello python hello.py arg1 arg2

# Run with environment variables
docker run --rm -e CUSTOM_VAR=value python-hello
```

## 📖 Dockerfile Explanation

### Base Image Selection
```dockerfile
FROM python:3.11-slim
```
- **python:3.11-slim**: Official Python image with minimal OS
- **Size**: ~45MB (much smaller than full python:3.11 at ~380MB)
- **Security**: Fewer packages = smaller attack surface
- **Performance**: Faster download and startup times

### Security Best Practices
```dockerfile
RUN addgroup --gid 1001 --system appgroup && \
    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group appgroup
USER appgroup
```
- Creates non-root user for security
- Prevents privilege escalation attacks
- Follows principle of least privilege

### Python Optimizations
```dockerfile
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
```
- **PYTHONUNBUFFERED**: Ensures output appears immediately
- **PYTHONDONTWRITEBYTECODE**: Prevents .pyc file generation

### Dependency Management
```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
```
- Copies requirements first for better layer caching
- Uses `--no-cache-dir` to reduce image size
- Upgrades pip for latest security patches

## 🧪 Testing the Example

### Basic Functionality
```bash
# Test the application
docker run --rm python-hello

# Check Python version
docker run --rm python-hello python --version

# List installed packages
docker run --rm python-hello pip list
```

### Interactive Testing
```bash
# Run with interactive terminal
docker run -it --rm python-hello

# Access container shell
docker run -it --rm python-hello /bin/bash

# Inside container, you can:
python hello.py
ls -la
whoami
```

### Health Check Testing
```bash
# Build and run with health check
docker build -t python-hello .
docker run -d --name python-test python-hello sleep 60
docker ps  # Check health status
docker logs python-test
docker rm -f python-test
```

## 🔍 Exploring the Python Application

### Key Features Demonstrated

1. **System Information Display**
   ```python
   print(f"Python Version: {sys.version}")
   print(f"Platform: {sys.platform}")
   print(f"User ID: {os.getuid()}")
   ```

2. **Environment Variable Handling**
   ```python
   important_vars = ['PYTHONPATH', 'PYTHONUNBUFFERED']
   for var in important_vars:
       value = os.environ.get(var, 'Not set')
       print(f"{var}: {value}")
   ```

3. **File System Operations**
   ```python
   files = os.listdir('.')
   print(f"Files in current directory: {files}")
   ```

4. **Interactive vs Non-interactive Detection**
   ```python
   if os.isatty(sys.stdin.fileno()):
       name = input("Enter your name: ")
   ```

## ⚙️ Configuration Options

### Environment Variables
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `PYTHONUNBUFFERED` | Disable output buffering | `1` | `1` |
| `PYTHONDONTWRITEBYTECODE` | Disable .pyc files | `1` | `1` |
| `PYTHONPATH` | Python module search path | Not set | `/app/modules` |

### Runtime Arguments
```bash
# Pass arguments to the script
docker run --rm python-hello python hello.py --verbose

# Set custom environment
docker run --rm -e CUSTOM_MESSAGE="Hello Docker!" python-hello
```

## 🛠️ Development Mode

### Volume Mounting for Development
```bash
# Mount current directory for live editing
docker run -it --rm -v $(pwd):/app python-hello

# Run with different Python files
docker run --rm -v $(pwd):/app python-hello python your_script.py
```

### Debugging Mode
```bash
# Run with Python debugger
docker run -it --rm python-hello python -m pdb hello.py

# Install additional packages for debugging
docker run -it --rm python-hello pip install ipdb
```

## 🔒 Security Considerations

### Image Security
- Uses official Python slim image (regularly updated)
- Runs as non-root user (UID 1001)
- No unnecessary packages installed
- Dependencies pinned to specific versions

### Runtime Security
```bash
# Run with read-only filesystem
docker run --rm --read-only python-hello

# Limit resources
docker run --rm --memory=128m --cpus=0.5 python-hello

# Drop capabilities
docker run --rm --cap-drop=ALL python-hello
```

## 📊 Performance Analysis

### Image Size Optimization
```bash
# Check image size
docker images python-hello

# Compare with different base images
docker build -f Dockerfile.alpine -t python-hello-alpine .
docker build -f Dockerfile.distroless -t python-hello-distroless .
```

### Runtime Performance
- **Memory Usage**: ~15-20MB
- **Startup Time**: ~0.5 seconds
- **CPU Usage**: Minimal for this simple script

## 🔗 Integration Examples

### With Docker Compose
```yaml
version: '3.8'
services:
  python-app:
    build: .
    environment:
      - PYTHONUNBUFFERED=1
      - LOG_LEVEL=INFO
    volumes:
      - app_data:/app/data
```

### With Other Containers
```bash
# Network with other containers
docker network create python-network
docker run -d --network python-network --name python-app python-hello sleep 300
docker run --rm --network python-network alpine ping python-app
```

## 🎓 Key Concepts Learned

1. **Python Containerization**: How to containerize Python applications effectively
2. **Dependency Management**: Using requirements.txt and pip in containers
3. **Security**: Running as non-root user and setting proper permissions
4. **Environment Configuration**: Python-specific environment variables
5. **Image Optimization**: Using slim images and avoiding unnecessary files
6. **Interactive Execution**: Handling different execution modes

## 🔗 Next Steps

After mastering this example, try:
- [03-node-hello](../03-node-hello/) - Basic Node.js application
- [04-static-website](../04-static-website/) - Nginx serving static content
- [05-python-flask](../05-python-flask/) - Python web application with Flask

## 🐛 Troubleshooting

### Common Issues

#### Python Module Not Found
**Problem**: ImportError or ModuleNotFoundError
```
ModuleNotFoundError: No module named 'requests'
```

**Solutions**:
```bash
# Check if requirements.txt is properly copied
docker run --rm python-hello pip list

# Rebuild with cache disabled
docker build --no-cache -t python-hello .

# Check requirements.txt syntax
cat requirements.txt
```

#### Permission Denied
**Problem**: Cannot write files or access directories
```
PermissionError: [Errno 13] Permission denied
```

**Solutions**:
```bash
# Check user ID in container
docker run --rm python-hello id

# Fix ownership in Dockerfile
RUN chown -R appgroup:appgroup /app

# Or run as root for debugging (not recommended for production)
docker run --rm --user root python-hello
```

#### Container Exits Immediately
**Problem**: Container stops right after starting
```
Container exited with code 0
```

**Solutions**:
```bash
# Check logs
docker run --name python-test python-hello
docker logs python-test
docker rm python-test

# Run interactively for debugging
docker run -it --rm python-hello /bin/bash

# Add sleep to keep container running
docker run --rm python-hello sh -c "python hello.py && sleep 30"
```

#### Package Installation Fails
**Problem**: pip install fails during build
```
ERROR: Could not find a version that satisfies the requirement
```

**Solutions**:
```bash
# Update pip first
RUN pip install --upgrade pip

# Use specific package versions
# In requirements.txt: requests==2.31.0

# Clear pip cache
RUN pip install --no-cache-dir -r requirements.txt
```

---

**Difficulty**: Beginner  
**Estimated Time**: 15 minutes  
**Technologies**: Python 3.11, pip, Docker security  
**Related Examples**: [01-hello-world](../01-hello-world/), [05-python-flask](../05-python-flask/)
