# syntax=docker/dockerfile:1

#############################################
# Stage 1: Builder
# This stage installs all dependencies
#############################################
FROM python:3.11-slim AS builder

# Add metadata
LABEL stage="builder"
LABEL description="Build stage for Python Flask application"

# Set working directory
WORKDIR /app

# Install build dependencies
# These are only needed during the build process
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Create virtual environment and install dependencies
# Using a virtual environment makes it easier to copy to final stage
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .


#############################################
# Stage 2: Runtime (Production)
# This stage only contains what's needed to run
#############################################
FROM python:3.11-slim AS production

# Add metadata
LABEL maintainer="Dockerfile Examples Project"
LABEL description="Flask web application demonstrating multi-stage Docker builds"
LABEL version="1.0"
LABEL stage="production"

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN addgroup --gid 1001 --system appgroup && \
    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group appgroup

# Copy virtual environment from builder stage
# This includes all installed packages but not the build tools
COPY --from=builder /opt/venv /opt/venv

# Copy application code from builder
COPY --from=builder /app/app.py .

# Change ownership
RUN chown -R appgroup:appgroup /app

# Switch to non-root user
USER appgroup

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    FLASK_APP=app.py \
    PORT=5000

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/api/health')" || exit 1

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
