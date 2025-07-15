# Hello World Docker Example

A simple Docker container that demonstrates the basics of containerization by printing a hello world message.

## 🎯 What You'll Learn

- Basic Dockerfile syntax
- Using Alpine Linux as a minimal base image
- Creating and executing scripts inside containers
- Using labels for metadata
- Setting up CMD instruction

## 📋 Prerequisites

- Docker installed and running
- Basic command line knowledge

## 🚀 Quick Start

1. **Build the image**:
   ```bash
   docker build -t hello-world .
   ```

2. **Run the container**:
   ```bash
   docker run hello-world
   ```

3. **Expected output**:
   ```
   Hello, Docker World!
   Container is running successfully!
   Current date: Mon Jul 15 10:30:45 UTC 2024
   ```

## 📖 Dockerfile Explanation

Let's break down each part of the Dockerfile:

### Base Image Selection
```dockerfile
FROM alpine:latest
```
- **alpine:latest**: Uses Alpine Linux, a minimal Linux distribution (~5MB)
- Perfect for simple containers and learning
- Much smaller than Ubuntu (~28MB) or other distributions

### Metadata Labels
```dockerfile
LABEL maintainer="Dockerfile Examples Project"
LABEL description="Simple Hello World Docker container"
LABEL version="1.0"
```
- Labels provide metadata about the image
- Useful for documentation and organization
- Can be viewed with `docker inspect image-name`

### Script Creation
```dockerfile
RUN echo '#!/bin/sh' > /hello.sh && \
    echo 'echo "Hello, Docker World!"' >> /hello.sh && \
    echo 'echo "Container is running successfully!"' >> /hello.sh && \
    echo 'echo "Current date: $(date)"' >> /hello.sh && \
    chmod +x /hello.sh
```
- Creates a shell script inside the container
- Uses `&&` to chain commands in a single layer
- Makes the script executable with `chmod +x`

### Default Command
```dockerfile
CMD ["/hello.sh"]
```
- Sets the default command to run when container starts
- Uses exec form (preferred over shell form)
- Container will exit after script completes

## 🔍 Exploring the Container

### Interactive Mode
Run the container interactively to explore:
```bash
docker run -it hello-world /bin/sh
```

Inside the container, you can:
```bash
# Check the operating system
cat /etc/os-release

# List files
ls -la /

# Run the hello script manually
/hello.sh

# Exit the container
exit
```

### Image Information
Check image details:
```bash
# View image information
docker images hello-world

# Inspect the image
docker inspect hello-world

# View image history
docker history hello-world
```

## 🧪 Experiments to Try

### 1. Modify the Message
Edit the Dockerfile to change the hello message:
```dockerfile
echo 'echo "Welcome to Docker containerization!"' >> /hello.sh
```

### 2. Add More Information
Include system information in the script:
```dockerfile
echo 'echo "Hostname: $(hostname)"' >> /hello.sh
echo 'echo "User: $(whoami)"' >> /hello.sh
```

### 3. Different Base Images
Try different base images to see size differences:
```dockerfile
# Try Ubuntu
FROM ubuntu:latest

# Try a distroless image
FROM gcr.io/distroless/static
```

## 🎓 Key Concepts Learned

1. **Dockerfile Structure**: Understanding basic Dockerfile commands
2. **Image Layers**: Each RUN command creates a new layer
3. **Base Images**: Importance of choosing appropriate base images
4. **Container Lifecycle**: How containers start, run, and exit
5. **Exec vs Shell Form**: Different ways to specify commands

## 🔗 Next Steps

After mastering this example, try:
- [02-python-hello](../02-python-hello/) - Hello world with Python
- [03-node-hello](../03-node-hello/) - Hello world with Node.js
- [04-static-website](../04-static-website/) - Serving static content

## 🐛 Troubleshooting

### Container Exits Immediately
If the container exits without output:
```bash
# Check container logs
docker logs $(docker ps -lq)

# Run with interactive terminal
docker run -it hello-world
```

### Permission Denied
If you get permission errors:
```bash
# On Linux, add user to docker group
sudo usermod -aG docker $USER
# Then log out and log back in

# Or run with sudo
sudo docker build -t hello-world .
```

### Build Context Issues
If build is slow:
```bash
# Create .dockerignore file
echo ".git" > .dockerignore
echo "*.log" >> .dockerignore
```

---

This example provides a solid foundation for understanding Docker containers. The concepts learned here apply to all containerized applications, from simple scripts to complex microservices.
