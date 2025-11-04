# syntax=docker/dockerfile:1

#############################################
# Stage 1: Dependencies
# Install ALL dependencies (including dev)
#############################################
FROM node:20-alpine AS dependencies

# Add metadata
LABEL stage="dependencies"
LABEL description="Install all dependencies including devDependencies"

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies)
# This is useful for potential build/test stages
RUN npm ci --include=dev

#############################################
# Stage 2: Builder
# Build/prepare the application
#############################################
FROM node:20-alpine AS builder

# Add metadata
LABEL stage="builder"
LABEL description="Build stage for Node.js application"

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ONLY production dependencies
# This creates a clean node_modules with production deps only
RUN npm ci --omit=dev && \
    npm cache clean --force

# Copy application code
COPY server.js ./

# Optional: Run any build steps here (TypeScript compilation, etc.)
# For this example, we're using plain JavaScript, so no build needed

#############################################
# Stage 3: Production Runtime
# Minimal production image
#############################################
FROM node:20-alpine AS production

# Add metadata
LABEL maintainer="Dockerfile Examples Project"
LABEL description="Express.js API demonstrating multi-stage Docker builds"
LABEL version="1.0"
LABEL stage="production"

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy production node_modules from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application code
COPY --from=builder --chown=nodejs:nodejs /app/server.js ./
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

# Switch to non-root user
USER nodejs

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    DOCKER_CONTAINER=true

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "server.js"]


#############################################
# Stage 4: Development (Optional)
# Development environment with hot-reload
#############################################
FROM node:20-alpine AS development

LABEL stage="development"
LABEL description="Development environment with hot-reload"

# Install dumb-init
RUN apk add --no-cache dumb-init

WORKDIR /app

# Copy all dependencies (including devDependencies)
COPY --from=dependencies /app/node_modules ./node_modules

# Copy package files
COPY package*.json ./

# Copy application code
COPY server.js ./

# Set development environment
ENV NODE_ENV=development \
    PORT=3000 \
    DOCKER_CONTAINER=true

EXPOSE 3000

# Use nodemon for hot-reload in development
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "dev"]
