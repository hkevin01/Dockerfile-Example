# syntax=docker/dockerfile:1

# Use the official Python slim image
FROM python:3.11-slim

# Add metadata
LABEL maintainer="Dockerfile Examples Project"
LABEL description="Basic Python script container demonstrating Python containerization"
LABEL version="1.0"

# Set working directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup --gid 1001 --system appgroup && \
    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group appgroup

# Copy Python script and requirements
COPY requirements.txt .
COPY hello.py .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Change ownership of the app directory
RUN chown -R appgroup:appgroup /app

# Switch to non-root user
USER appgroup

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import sys; sys.exit(0)" || exit 1

# Run the Python script
CMD ["python", "hello.py"]
