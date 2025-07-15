# syntax=docker/dockerfile:1

# Use a minimal base image
FROM alpine:latest

# Add metadata
LABEL maintainer="Dockerfile Examples Project"
LABEL description="Simple Hello World Docker container"
LABEL version="1.0"

# Create a simple script that outputs hello world
RUN echo '#!/bin/sh' > /hello.sh && \
    echo 'echo "Hello, Docker World!"' >> /hello.sh && \
    echo 'echo "Container is running successfully!"' >> /hello.sh && \
    echo 'echo "Current date: $(date)"' >> /hello.sh && \
    chmod +x /hello.sh

# Set the script as the default command
CMD ["/hello.sh"]
