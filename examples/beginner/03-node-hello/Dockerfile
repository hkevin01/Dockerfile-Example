# syntax=docker/dockerfile:1

# Use the official Node.js LTS alpine image
FROM node:18-alpine

# Add metadata
LABEL maintainer="Dockerfile Examples Project"
LABEL description="Basic Node.js application demonstrating Node.js containerization"
LABEL version="1.0"

# Set working directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup -g 1001 -S nodegroup && \
    adduser -S nodeuser -u 1001 -G nodegroup

# Copy package files first for better layer caching
COPY package*.json ./

# Install dependencies as root, then change ownership
RUN npm ci --only=production --silent && \
    npm cache clean --force

# Copy application files
COPY . .

# Change ownership of the app directory to nodeuser
RUN chown -R nodeuser:nodegroup /app

# Switch to non-root user
USER nodeuser

# Set environment variables
ENV NODE_ENV=production
ENV NPM_CONFIG_LOGLEVEL=warn

# Expose the application port
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Start the application
CMD ["node", "app.js"]
