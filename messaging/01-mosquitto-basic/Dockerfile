# syntax=docker/dockerfile:1

# Use the official Eclipse Mosquitto image
FROM eclipse-mosquitto:2.0

# Add metadata
LABEL maintainer="Dockerfile Examples Project"
LABEL description="Basic Mosquitto MQTT broker setup"
LABEL version="1.0"

# Copy custom configuration
COPY mosquitto.conf /mosquitto/config/mosquitto.conf

# Expose MQTT port
EXPOSE 1883

# Expose WebSocket port (optional)
EXPOSE 9001

# Create volume for persistent data
VOLUME ["/mosquitto/data", "/mosquitto/log"]

# The base image already sets the correct CMD
# CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
