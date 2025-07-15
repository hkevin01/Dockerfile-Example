# Basic Mosquitto MQTT Broker

A containerized MQTT broker using Eclipse Mosquitto, perfect for IoT applications, real-time messaging, and learning MQTT protocol basics.

## 🎯 What You'll Learn

- Setting up an MQTT broker with Docker
- MQTT protocol basics (publish/subscribe)
- Container networking and port mapping
- Volume management for persistent data
- WebSocket support for web clients
- Docker Compose for multi-service applications

## 📋 Prerequisites

- Docker and Docker Compose installed
- Basic understanding of messaging concepts
- MQTT client tools (optional, for testing)

## 🚀 Quick Start

### Option 1: Docker Build and Run

1. **Build the image**:
   ```bash
   docker build -t mosquitto-basic .
   ```

2. **Run the broker**:
   ```bash
   docker run -d \
     --name mosquitto-broker \
     -p 1883:1883 \
     -p 9001:9001 \
     mosquitto-basic
   ```

### Option 2: Docker Compose (Recommended)

1. **Start the broker**:
   ```bash
   docker-compose up -d
   ```

2. **Check if it's running**:
   ```bash
   docker-compose ps
   docker-compose logs mosquitto
   ```

## 🧪 Testing the MQTT Broker

### Using Command Line Tools

1. **Subscribe to a topic** (in one terminal):
   ```bash
   # Using Docker
   docker exec -it mosquitto-broker mosquitto_sub -h localhost -t "test/topic"
   
   # Or if you have mosquitto-clients installed locally
   mosquitto_sub -h localhost -p 1883 -t "test/topic"
   ```

2. **Publish a message** (in another terminal):
   ```bash
   # Using Docker
   docker exec -it mosquitto-broker mosquitto_pub -h localhost -t "test/topic" -m "Hello MQTT!"
   
   # Or locally
   mosquitto_pub -h localhost -p 1883 -t "test/topic" -m "Hello MQTT!"
   ```

### Using Docker Compose Testing Profile

```bash
# Start broker and test client
docker-compose --profile testing up

# In another terminal, publish a message
docker-compose exec mosquitto mosquitto_pub -h mosquitto -t "test/topic" -m "Hello from Docker Compose!"
```

## 📊 Monitoring and Management

### View Logs
```bash
# Follow logs
docker-compose logs -f mosquitto

# View specific number of lines
docker logs --tail 50 mosquitto-broker
```

### Connect to Broker
```bash
# Interactive shell
docker exec -it mosquitto-broker sh

# Check broker status
docker exec mosquitto-broker mosquitto_pub -h localhost -t '$SYS/broker/uptime' -n
```

### WebSocket Testing
You can test WebSocket connectivity using a web-based MQTT client:
- Open your browser to any online MQTT WebSocket client
- Connect to `ws://localhost:9001`
- Subscribe/publish to topics

## 📖 Configuration Explanation

### mosquitto.conf
```conf
# Allow connections without authentication (development only)
allow_anonymous true

# Standard MQTT port
listener 1883

# WebSocket support for web clients
listener 9001
protocol websockets

# Persistent storage
persistence true
persistence_location /mosquitto/data/
```

### Docker Compose Features
- **Persistent volumes**: Data survives container restarts
- **Custom network**: Isolated network for MQTT services
- **Health checks**: Ensure broker is responding
- **Testing profile**: Separate client for testing

## 🔒 Security Considerations

⚠️ **Warning**: This example allows anonymous connections for learning purposes.

### For Production Use:

1. **Enable authentication**:
   ```conf
   allow_anonymous false
   password_file /mosquitto/config/passwd
   ```

2. **Create password file**:
   ```bash
   docker exec -it mosquitto-broker mosquitto_passwd -c /mosquitto/config/passwd username
   ```

3. **Use TLS encryption**:
   ```conf
   listener 8883
   certfile /mosquitto/config/server.crt
   keyfile /mosquitto/config/server.key
   ```

## 🛠️ Advanced Configuration

### Custom mosquitto.conf Options
```conf
# Connection limits
max_connections 1000
max_connections_per_ip 50

# Message retention
retained_persistence true
max_retained_messages 1000

# Logging levels
log_type error
log_type warning
log_type notice
log_type information
log_type debug

# Client timeouts
keepalive_interval 60
max_keepalive 3600
```

### Environment Variables
You can override settings using environment variables:
```yaml
services:
  mosquitto:
    environment:
      - MOSQUITTO_LOG_TYPE=debug
```

## 📱 Real-world Use Cases

### IoT Sensor Network
```bash
# Temperature sensor data
mosquitto_pub -h localhost -t "sensors/temperature/room1" -m "22.5"
mosquitto_pub -h localhost -t "sensors/temperature/room2" -m "21.8"

# Subscribe to all temperature sensors
mosquitto_sub -h localhost -t "sensors/temperature/+"
```

### Home Automation
```bash
# Light control
mosquitto_pub -h localhost -t "home/living-room/lights" -m "ON"
mosquitto_pub -h localhost -t "home/kitchen/lights" -m "OFF"

# Subscribe to all home automation topics
mosquitto_sub -h localhost -t "home/+/+"
```

### System Monitoring
```bash
# System stats
mosquitto_pub -h localhost -t "system/cpu/usage" -m "45.2"
mosquitto_pub -h localhost -t "system/memory/usage" -m "78.5"
```

## 🔗 MQTT Topic Patterns

### Wildcards
- `+`: Single level wildcard
  - `sensors/+/temperature` matches `sensors/room1/temperature`
- `#`: Multi-level wildcard
  - `sensors/#` matches all topics starting with `sensors/`

### Best Practices
- Use hierarchical topic structure: `building/floor/room/device/sensor`
- Avoid leading forward slash: `topic/subtopic` not `/topic/subtopic`
- Use retained messages for device status
- Implement proper QoS levels (0, 1, 2)

## 🧩 Integration Examples

### Python Client
```python
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code {rc}")
    client.subscribe("test/topic")

def on_message(client, userdata, msg):
    print(f"Topic: {msg.topic}, Message: {msg.payload.decode()}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("localhost", 1883, 60)
client.loop_forever()
```

### Node.js Client
```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://localhost:1883');

client.on('connect', () => {
    console.log('Connected to MQTT broker');
    client.subscribe('test/topic');
});

client.on('message', (topic, message) => {
    console.log(`Topic: ${topic}, Message: ${message.toString()}`);
});
```

## 🔗 Next Steps

After mastering this basic setup, explore:
- [02-mqtt-auth](../02-mqtt-auth/) - Authentication and authorization
- [03-mqtt-ssl](../03-mqtt-ssl/) - SSL/TLS encryption
- [04-mqtt-clustering](../04-mqtt-clustering/) - Broker clustering
- [05-iot-sensors](../05-iot-sensors/) - Simulated IoT sensor network

## 🐛 Troubleshooting

### Broker Won't Start
```bash
# Check logs
docker-compose logs mosquitto

# Common issues:
# - Port already in use
# - Configuration file errors
# - Permission issues with volumes
```

### Can't Connect to Broker
```bash
# Test connectivity
telnet localhost 1883

# Check if port is open
netstat -tulpn | grep :1883

# Verify container networking
docker network inspect mosquitto_mqtt_network
```

### Messages Not Received
```bash
# Check client connection
mosquitto_sub -h localhost -t '$SYS/broker/clients/connected'

# Verify topic spelling and wildcards
mosquitto_sub -h localhost -t '#'  # Subscribe to all topics
```

---

This MQTT broker setup provides a solid foundation for any messaging application, from simple IoT prototypes to complex distributed systems. The persistent storage and WebSocket support make it production-ready with proper security configuration.
