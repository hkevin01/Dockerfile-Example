# 🚀 Quick Start Guide

Get up and running with Docker multi-stage builds in 5 minutes!

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Basic command line knowledge
- A text editor

## 🎯 Your First Multi-Stage Build

### Step 1: Choose Your Language

Pick the example that matches your stack:

```bash
# Python developers
cd examples/beginner/04-python-flask-multistage

# Node.js developers  
cd examples/intermediate/01-nodejs-express-multistage

# Go developers
cd examples/advanced/01-go-multistage
```

### Step 2: Build the Image

```bash
docker build -t my-first-multistage .
```

### Step 3: Run the Container

```bash
# Python Flask
docker run -p 5000:5000 my-first-multistage

# Node.js Express
docker run -p 3000:3000 my-first-multistage

# Go Server
docker run -p 8080:8080 my-first-multistage
```

### Step 4: Test It

```bash
# Python
curl http://localhost:5000

# Node.js
curl http://localhost:3000

# Go
curl http://localhost:8080
```

You should see a welcome message! 🎉

## 📊 See the Magic

Compare image sizes:

```bash
# Build single-stage version (big)
docker build -f Dockerfile.single -t big-image .

# Build multi-stage version (small)
docker build -t small-image .

# Compare sizes
docker images | grep -E 'big-image|small-image'
```

**Result**: Multi-stage builds are typically **60-99% smaller**!

## 🎓 What's Happening?

Multi-stage builds work in two phases:

1. **Build Stage**: Installs all dependencies and compiles code
2. **Runtime Stage**: Copies only the final artifacts needed to run

```dockerfile
# Stage 1: Build (large)
FROM python:3.11 AS builder
# ... install everything, compile, build ...

# Stage 2: Runtime (small)  
FROM python:3.11-slim
COPY --from=builder /app /app  # Only copy what's needed!
```

## 🏃 Next Steps

### Learn by Doing

1. **Beginner**: Start with simple examples
   ```bash
   cd examples/beginner/
   ```

2. **Intermediate**: Add complexity
   ```bash
   cd examples/intermediate/
   ```

3. **Advanced**: Master optimization
   ```bash
   cd examples/advanced/
   ```

### Understand the Patterns

Each example includes:
- 📄 Fully commented Dockerfile
- 📚 Detailed README
- 🧪 Test scripts
- 📊 Size comparison tools

### Run All Tests

```bash
bash tests/test-multistage-builds.sh
```

## 💡 Common Use Cases

### 1. Python Web Application

**Before (Single-Stage)**: 380 MB
```dockerfile
FROM python:3.11
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

**After (Multi-Stage)**: 151 MB
```dockerfile
FROM python:3.11 AS builder
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . .
CMD ["python", "app.py"]
```

### 2. Node.js Application

**Before**: 395 MB → **After**: 138 MB

Key technique: Separate dev and production dependencies

### 3. Go Application

**Before**: 800 MB → **After**: 4.58 MB

Ultimate optimization: Use `scratch` base image!

## 🔍 Troubleshooting

### Build Failed?

```bash
# Check Docker version
docker version

# Enable BuildKit for better error messages
export DOCKER_BUILDKIT=1
docker build -t myapp .
```

### Container Won't Start?

```bash
# Check logs
docker logs <container-id>

# Run interactively to debug
docker run -it myapp /bin/sh
```

### Image Too Large?

```bash
# Analyze layers
docker history myapp

# Use dive for detailed analysis
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest myapp
```

## 📚 Resources

- **Full Documentation**: See [README.md](../README.md)
- **Best Practices**: Check [docs/best-practices.md](best-practices.md)
- **Workflow Guide**: Read [WORKFLOW.md](../WORKFLOW.md)
- **Project Goals**: Review [PROJECT_GOALS.md](../PROJECT_GOALS.md)

## 🤝 Get Help

- **Issues**: Check existing examples in the repo
- **Questions**: Review the comprehensive READMEs in each example
- **Contribute**: See [WORKFLOW.md](../WORKFLOW.md) for contribution guidelines

## 🎯 Challenge Yourself

Once you're comfortable with the basics:

1. Convert your own project to multi-stage builds
2. Measure the size reduction
3. Implement security best practices (non-root user, health checks)
4. Set up automated testing
5. Integrate with CI/CD

## 🌟 Key Takeaways

✅ Multi-stage builds reduce image size by 60-99%
✅ Smaller images = faster deployments + lower costs
✅ More secure (fewer tools in production image)
✅ Production-ready pattern used by major companies
✅ Easy to implement with minimal code changes

Happy building! 🐳
