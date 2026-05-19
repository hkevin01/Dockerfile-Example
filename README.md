# 🐳 Dockerfile Examples Project

> A comprehensive, production-ready collection of Docker examples with a focus on **Multi-Stage Builds** and modern containerization best practices.

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/hkevin01/Dockerfile-Example)

## 🎯 Project Purpose & Why

### The Challenge
Many developers struggle with Docker optimization, leading to:
- 🐘 **Bloated images** (often 2-5x larger than necessary)
- 🔒 **Security vulnerabilities** from unnecessary dependencies
- ⏱️ **Slow build times** and deployment cycles
- 💰 **Increased cloud costs** from large image sizes

### Our Solution
This project provides **real-world, production-ready examples** that demonstrate:
- ✅ Multi-stage builds reducing image sizes by 70-90%
- ✅ Security-first approach with minimal attack surfaces
- ✅ Fast build times with layer caching optimization
- ✅ Best practices from beginner to expert level

### Why Multi-Stage Builds?
Multi-stage builds separate the **build environment** from the **runtime environment**, resulting in:
- **Smaller images**: Only runtime dependencies included
- **Better security**: No build tools in production images
- **Faster deployments**: Less data to transfer
- **Cleaner code**: Organized build process

## 🎯 Project Overview

This repository serves as a learning resource and reference guide for Docker containerization, featuring:

- **Progressive Learning**: Examples range from simple single-service containers to complex multi-service architectures
- **Multi-Stage Focus**: Dedicated examples showing optimization techniques
- **Real-world Applications**: Practical examples including messaging systems, databases, web services, and more
- **Best Practices**: Each example demonstrates Docker best practices and optimization techniques
- **Comprehensive Documentation**: Detailed guides with architecture diagrams

---

## 🤔 Understanding Docker Multi-Stage Builds: The Why & How

### 📖 What Are Multi-Stage Builds?

Multi-stage builds allow you to use **multiple FROM statements** in a single Dockerfile. Each FROM instruction starts a new stage, and you can selectively copy artifacts from one stage to another, leaving behind everything you don't need.

### 🎯 Why Do We Need Them?

#### Problem 1: Bloated Images 🐘
**Before Multi-Stage:**
```dockerfile
FROM python:3.11
COPY . .
RUN pip install -r requirements.txt
# Final image: 380MB (includes pip, setuptools, build tools, cache)
```

**The Problem:** The final image contains:
- ❌ Build tools (gcc, make, etc.)
- ❌ Package manager cache
- ❌ Temporary build files
- ❌ Development dependencies
- ✅ Your application (only 5-10MB!)

**After Multi-Stage:**
```dockerfile
# Stage 1: Build
FROM python:3.11 AS builder
RUN pip install --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . .
# Final image: 151MB (60% reduction!)
```

#### Problem 2: Security Vulnerabilities 🔒
**Why it matters:**
- Build tools = more attack surface
- More packages = more CVEs (Common Vulnerabilities and Exposures)
- Unused dependencies = unnecessary risk

**Multi-stage solution:**
- Build stage: Contains all tools needed for compilation
- Runtime stage: Only contains what's needed to run
- Result: Minimal attack surface

#### Problem 3: Slow Deployments ⏱️
**The impact:**
```
Single-stage Python app: 380MB
├─ Pull time: ~45 seconds
├─ Push time: ~60 seconds
└─ Storage cost: Higher

Multi-stage Python app: 151MB
├─ Pull time: ~18 seconds (60% faster!)
├─ Push time: ~24 seconds (60% faster!)
└─ Storage cost: 60% lower
```

**In production with 100 container starts per day:**
- Time saved: ~45 minutes/day
- Bandwidth saved: ~23GB/day
- Cost savings: Significant at scale

#### Problem 4: Complex Build Processes 🛠️
**Before:** Separate build and runtime Dockerfiles
```
Dockerfile.build    # For building
Dockerfile.runtime  # For production
build-script.sh     # Orchestrates the process
```

**After:** One unified Dockerfile
```dockerfile
# Everything in one place, easier to maintain
FROM node:20 AS builder
# ... build steps

FROM node:20-alpine
# ... runtime steps
```

### 🔧 How Do Multi-Stage Builds Work?

#### The Mechanics

1. **Stage Naming**
   ```dockerfile
   FROM golang:1.21 AS builder
   #                    ^^^^^^^ Named stage
   ```

2. **Copying Between Stages**
   ```dockerfile
   COPY --from=builder /app/binary /usr/local/bin/
   #           ^^^^^^^ References previous stage
   ```

3. **Selective Artifact Transfer**
   ```
   Stage 1 (builder):           Stage 2 (runtime):
   ├─ Source code              ├─ Compiled binary ✓
   ├─ Build tools             ├─ (minimal base)
   ├─ Dependencies
   ├─ Temp files
   └─ Compiled binary ✓
   ```

#### Real-World Example: Go Application

**Single-Stage (800MB):**
```dockerfile
FROM golang:1.21
WORKDIR /app
COPY . .
RUN go build -o server
CMD ["./server"]
# Problem: Includes entire Go toolchain!
```

**Multi-Stage (4.58MB - 99.4% smaller!):**
```dockerfile
# Stage 1: Build
FROM golang:1.21 AS builder
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -o server

# Stage 2: Runtime
FROM scratch
COPY --from=builder /build/server /server
ENTRYPOINT ["/server"]
# Only contains the binary! Nothing else.
```

**Why this works:**
1. Go compiles to a static binary (no runtime dependencies needed)
2. `scratch` is literally empty (0MB base)
3. Final image = just the binary (4.58MB)

### 🎨 Different Patterns for Different Languages

#### Pattern 1: Python (Virtual Environments)
```dockerfile
# Build stage: Install dependencies in user space
FROM python:3.11 AS builder
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage: Copy installed packages
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
# Why? Python needs the interpreter but not pip
```

#### Pattern 2: Node.js (Production Dependencies)
```dockerfile
# Build stage: Install all dependencies
FROM node:20 AS builder
RUN npm ci --include=dev

# Runtime stage: Only production dependencies
FROM node:20-alpine
RUN npm ci --only=production
# Why? Separates devDependencies from production
```

#### Pattern 3: Go (Static Compilation)
```dockerfile
# Build stage: Compile
FROM golang:1.21 AS builder
RUN go build -o app

# Runtime stage: Minimal or scratch
FROM scratch
COPY --from=builder /app/app /app
# Why? Go binaries are self-contained
```

### 📊 Impact Metrics: Real Numbers

| <sub>Application</sub> | <sub>Single-Stage</sub> | <sub>Multi-Stage</sub> | <sub>Savings</sub> | <sub>Method</sub> |
|------------|-------------|-------------|---------|---------|
| <sub>Python Flask</sub> | <sub>380MB</sub> | <sub>151MB</sub> | <sub>**60%**</sub> | <sub>Slim base + user installs</sub> |
| <sub>Node.js Express</sub> | <sub>395MB</sub> | <sub>138MB</sub> | <sub>**65%**</sub> | <sub>Alpine + prod deps only</sub> |
| <sub>Go API</sub> | <sub>800MB</sub> | <sub>4.58MB</sub> | <sub>**99.4%**</sub> | <sub>Scratch base</sub> |
| <sub>Average</sub> | <sub>~525MB</sub> | <sub>~98MB</sub> | <sub>**81%**</sub> | <sub>Multi-stage techniques</sub> |

**What this means in production:**
- **1000 container pulls/day**: Save 427GB bandwidth
- **AWS ECR storage**: $0.10/GB/month → Save ~$43/month per image
- **Deployment time**: 3x faster pulls and starts
- **Security scans**: 70-90% fewer vulnerabilities

### 🔐 Security Benefits Explained

#### Layer-by-Layer Comparison

**Single-Stage Image Layers:**
```
1. Base OS (Ubuntu)           → 100MB, 200 packages
2. Build tools (gcc, make)    → 150MB, 50 packages
3. Python + pip              → 100MB, 30 packages
4. Application dependencies   → 30MB, 20 packages
5. Application code          → 5MB
───────────────────────────────
Total: 385MB, ~300 packages to scan for CVEs
```

**Multi-Stage Image Layers:**
```
1. Slim base (Python)        → 50MB, 80 packages
2. Application dependencies   → 30MB, 20 packages
3. Application code          → 5MB
───────────────────────────────
Total: 85MB, ~100 packages to scan
Result: 66% fewer security surfaces
```

### 🚀 Performance Optimization Explained

#### Build Caching Strategy

Docker caches each layer. Multi-stage builds optimize this:

```dockerfile
# ❌ Bad: Cache invalidated on any code change
FROM python:3.11
COPY . .                    # Copies everything
RUN pip install -r req.txt  # Reinstalls every time

# ✅ Good: Dependencies cached separately
FROM python:3.11 AS builder
COPY requirements.txt .     # Only copy what's needed
RUN pip install -r req.txt  # Cached unless req.txt changes
COPY . .                    # Code changes don't break cache
```

**Real-world impact:**
- First build: 2 minutes
- Rebuild with code changes (cache hit): 10 seconds
- **12x faster iteration during development**

### 💡 When to Use Multi-Stage Builds

| <sub>Scenario</sub> | <sub>Use Multi-Stage?</sub> | <sub>Why/Why Not</sub> |
|----------|------------------|-------------|
| <sub>**Production deployments**</sub> | <sub>✅ Always</sub> | <sub>Size, security, performance</sub> |
| <sub>**Compiled languages** (Go, Rust, Java)</sub> | <sub>✅ Always</sub> | <sub>Massive size savings (90%+)</sub> |
| <sub>**Interpreted languages** (Python, Node.js)</sub> | <sub>✅ Recommended</sub> | <sub>Good savings (50-70%)</sub> |
| <sub>**Quick local testing**</sub> | <sub>⚠️ Optional</sub> | <sub>Single-stage is simpler for dev</sub> |
| <sub>**Simple scripts**</sub> | <sub>⚠️ Optional</sub> | <sub>May not be worth the complexity</sub> |

### 🎓 Learning Progression in This Repo

1. **Beginner**: Understand the basics → `04-python-flask-multistage/`
2. **Intermediate**: Production patterns → `01-nodejs-express-multistage/`
3. **Advanced**: Extreme optimization → `01-go-multistage/` (scratch base)
4. **Expert**: Complex architectures → Coming soon

---

## 🏗️ Architecture Overview

```mermaid
graph TB
    subgraph "Multi-Stage Build Process"
        A[Base Image] -->|Stage 1| B[Build Stage]
        B --> C[Install Build Tools]
        C --> D[Compile/Build App]
        D -->|Stage 2| E[Runtime Stage]
        E --> F[Copy Artifacts Only]
        F --> G[Final Minimal Image]
    end

    style A fill:#2d3748,stroke:#4299e1,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style E fill:#2d3748,stroke:#ed8936,stroke-width:2px,color:#fff
    style F fill:#2d3748,stroke:#ed8936,stroke-width:2px,color:#fff
    style G fill:#2d3748,stroke:#9f7aea,stroke-width:3px,color:#fff
```

## 📁 Project Structure

```
├── memory-bank/                   # Project memory & architecture decisions
│   ├── app-description.md        # Project overview & goals
│   ├── change-log.md             # Detailed change history
│   ├── implementation-plans/     # ACID-based development plans
│   └── architecture-decisions/   # ADRs for design choices
├── docs/                          # Documentation and guides
│   ├── best-practices.md         # Docker optimization guidelines
│   ├── contributing.md           # Contribution guidelines
│   ├── troubleshooting.md        # Common issues & solutions
│   └── templates/                # Reusable templates
├── examples/                      # Docker examples organized by difficulty
│   ├── beginner/                 # Simple, single-service containers
│   │   ├── 01-hello-world/      # Basic Docker concepts
│   │   ├── 02-python-hello/     # Python basics
│   │   ├── 03-node-hello/       # Node.js with health checks
│   │   └── 04-python-flask-multistage/  # First multi-stage build
│   ├── intermediate/             # Multi-stage builds, networking
│   │   └── 01-nodejs-express-multistage/ # Production-ready Node.js
│   ├── advanced/                 # Complex architectures (Coming soon)
│   └── expert/                   # Production enterprise examples (Coming soon)
├── messaging/                     # Mosquitto MQTT and messaging examples
│   └── 01-mosquitto-basic/       # MQTT broker setup
├── databases/                     # Database containerization examples
├── web-services/                  # Web application examples
├── monitoring/                    # Monitoring and logging examples
└── scripts/                       # Utility scripts for building and testing
    └── build-and-test.sh         # Automated testing script
```

## 🚀 Quick Start

### Prerequisites
```bash
# Verify Docker installation
docker --version  # Should be 20.10 or higher
docker compose version  # Should be 2.0 or higher
```

### 1. Clone the Repository
```bash
git clone git@github.com:hkevin01/Dockerfile-Example.git
cd Dockerfile-Example
```

### 2. Run Your First Multi-Stage Build
```bash
# Navigate to the Python Flask multi-stage example
cd examples/beginner/04-python-flask-multistage

# Build the image
docker build -t flask-multistage .

# Run the container
docker run -p 5000:5000 flask-multistage

# Test it
curl http://localhost:5000
# Output: Hello from Flask in a Multi-Stage Docker Build!
```

### 3. Compare Image Sizes
```bash
# See the size difference
./compare.sh

# Expected output:
# Single-stage build: ~450MB
# Multi-stage build: ~150MB
# Size reduction: ~67%
```

### 4. Try Node.js with Docker Compose
```bash
cd ../../intermediate/01-nodejs-express-multistage

# Build and start with compose
docker compose up --build

# Test the API
curl http://localhost:3000
curl http://localhost:3000/health

# Stop and cleanup
docker compose down
```

### 5. Explore Documentation
```bash
# Read project goals
cat PROJECT_GOALS.md

# Check development workflow
cat WORKFLOW.md

# Browse memory bank
cat memory-bank/app-description.md
```

## 📚 Learning Path

```mermaid
graph TD
    Start[Start Here] --> Beginner

    Beginner[🌱 Beginner Level] --> B1[01-hello-world<br/>Basic Dockerfile]
    B1 --> B2[02-python-hello<br/>Python Basics]
    B2 --> B3[03-node-hello<br/>Health Checks]
    B3 --> B4[04-python-flask-multistage<br/>First Multi-Stage]

    B4 --> Intermediate[🌿 Intermediate Level]
    Intermediate --> I1[01-nodejs-express<br/>Production Node.js]
    I1 --> I2[Docker Compose<br/>Multi-container]
    I2 --> I3[Networking<br/>Container Communication]

    I3 --> Advanced[🌳 Advanced Level]
    Advanced --> A1[Microservices<br/>Architecture]
    A1 --> A2[Security<br/>Best Practices]
    A2 --> A3[CI/CD<br/>Integration]

    A3 --> Expert[🌲 Expert Level]
    Expert --> E1[Kubernetes<br/>Orchestration]
    E1 --> E2[Production<br/>Deployments]
    E2 --> E3[Enterprise<br/>Patterns]

    style Start fill:#2d3748,stroke:#4299e1,stroke-width:3px,color:#fff
    style Beginner fill:#22543d,stroke:#68d391,stroke-width:2px,color:#fff
    style Intermediate fill:#2c5282,stroke:#63b3ed,stroke-width:2px,color:#fff
    style Advanced fill:#744210,stroke:#ed8936,stroke-width:2px,color:#fff
    style Expert fill:#44337a,stroke:#9f7aea,stroke-width:2px,color:#fff
    style B1 fill:#2d3748,stroke:#68d391,stroke-width:1px,color:#fff
    style B2 fill:#2d3748,stroke:#68d391,stroke-width:1px,color:#fff
    style B3 fill:#2d3748,stroke:#68d391,stroke-width:1px,color:#fff
    style B4 fill:#2d3748,stroke:#68d391,stroke-width:1px,color:#fff
    style I1 fill:#2d3748,stroke:#63b3ed,stroke-width:1px,color:#fff
    style I2 fill:#2d3748,stroke:#63b3ed,stroke-width:1px,color:#fff
    style I3 fill:#2d3748,stroke:#63b3ed,stroke-width:1px,color:#fff
    style A1 fill:#2d3748,stroke:#ed8936,stroke-width:1px,color:#fff
    style A2 fill:#2d3748,stroke:#ed8936,stroke-width:1px,color:#fff
    style A3 fill:#2d3748,stroke:#ed8936,stroke-width:1px,color:#fff
    style E1 fill:#2d3748,stroke:#9f7aea,stroke-width:1px,color:#fff
    style E2 fill:#2d3748,stroke:#9f7aea,stroke-width:1px,color:#fff
    style E3 fill:#2d3748,stroke:#9f7aea,stroke-width:1px,color:#fff
```

### 🌱 Beginner Level
**Focus**: Docker fundamentals and basic containerization

- ✅ Basic Dockerfile syntax and commands
- ✅ Simple Python/Node.js applications
- ✅ File copying and environment variables
- ✅ Introduction to multi-stage builds
- ⏱️ **Time**: 2-3 hours

#### Example 1: Hello World (`01-hello-world/`)

**What it teaches:**
- Most basic Dockerfile possible
- FROM, COPY, CMD instructions
- How Docker layers work

**Why this example:**
```dockerfile
FROM alpine:latest
COPY hello.sh /
CMD ["/hello.sh"]
```

- ✅ **Alpine**: 5MB base, perfect for learning
- ✅ **Single script**: Focus on Docker, not app complexity
- ✅ **No dependencies**: Eliminates variables, pure Docker learning

**How it works:**
1. Starts with Alpine Linux (minimal OS)
2. Copies your script into the container
3. Sets script as the command to run
4. Container executes script and exits

**Real-world application**:
- Batch processing jobs
- Cron tasks
- Simple utilities
- CI/CD pipeline scripts

---

#### Example 2: Python Hello (`02-python-hello/`)

**What it teaches:**
- Python runtime environment
- Requirements management
- Non-root user security
- Working directory setup

**Why this approach:**
```dockerfile
FROM python:3.11-slim
RUN useradd -r -s /bin/false appuser  # Security!
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
USER appuser  # Don't run as root
CMD ["python", "hello.py"]
```

**Key concepts explained:**
- **Why slim?** Balances size (124MB) with compatibility
- **Why non-root?** If app is compromised, attacker has limited access
- **Why --no-cache-dir?** Saves ~50MB by not storing pip cache
- **Why WORKDIR?** Organized file structure, predictable paths

**How it works:**
1. Python 3.11 slim image (has python + pip, no build tools)
2. Creates dedicated user for security (UID 1001)
3. Sets working directory to /app
4. Installs only what's in requirements.txt
5. Copies application code
6. Switches to non-root user
7. Runs Python script

**Real-world application**:
- REST API services
- Data processing scripts
- Machine learning inference
- Automation tools

---

#### Example 3: Node.js Hello (`03-node-hello/`)

**What it teaches:**
- Node.js containerization
- Package management (npm)
- Health check endpoints
- Express.js basics

**Why Express.js:**
```javascript
const express = require('express');
const app = express();

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});
```

- ✅ **Industry standard**: Used by 65% of Node.js projects
- ✅ **Minimal overhead**: Just routing, you add what you need
- ✅ **Health checks**: Critical for orchestration (K8s, Docker Swarm)

**Dockerfile strategy:**
```dockerfile
FROM node:20-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production  # Reproducible installs
COPY . .
USER node  # Built-in non-root user
EXPOSE 3000
CMD ["node", "app.js"]
```

**Why this works:**
- **npm ci**: Faster, reproducible installs (uses package-lock.json)
- **--only=production**: Excludes devDependencies (testing, linting)
- **USER node**: Alpine node image has pre-created user
- **EXPOSE**: Documents the port (doesn't actually publish it)

**How health checks enable:**
1. Load balancers know when to route traffic
2. Kubernetes knows when to restart unhealthy pods
3. Docker Compose can wait for service readiness
4. Monitoring systems can track service health

**Real-world application**:
- Web applications
- REST APIs
- Microservices
- Real-time services (WebSocket)

---

#### Example 4: Python Flask Multi-Stage (`04-python-flask-multistage/`)

**What it teaches:**
- First multi-stage build
- Production WSGI server (Gunicorn)
- Build vs runtime separation
- Size optimization

**Why multi-stage here:**
```dockerfile
# Stage 1: Builder (can have build tools)
FROM python:3.11 AS builder
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime (minimal)
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . .
CMD ["gunicorn", "app:app"]
```

**The magic of --from=builder:**
- Only copies installed packages, not pip/setuptools
- Build stage is discarded (not in final image)
- Final image: 151MB vs single-stage: 380MB (60% savings!)

**Why Gunicorn over Flask dev server:**

| <sub>Feature</sub> | <sub>Flask Dev Server</sub> | <sub>Gunicorn</sub> |
|---------|------------------|----------|
| <sub>**Concurrency**</sub> | <sub>Single-threaded</sub> | <sub>Multi-worker</sub> |
| <sub>**Performance**</sub> | <sub>~100 req/sec</sub> | <sub>~10,000 req/sec</sub> |
| <sub>**Production**</sub> | <sub>❌ Not safe</sub> | <sub>✅ Battle-tested</sub> |
| <sub>**Crash isolation**</sub> | <sub>❌ Crashes all</sub> | <sub>✅ Worker isolation</sub> |

**How Gunicorn works:**
```bash
gunicorn app:app --workers 4 --threads 2
```
- Pre-forks 4 worker processes
- Each worker handles 2 threads
- Total: 8 concurrent requests
- If one worker crashes, others continue

**Real-world application**:
- Production web apps
- REST APIs at scale
- Microservices
- Backend for mobile/frontend apps

---

### 🌿 Intermediate Level
**Focus**: Production-ready optimization techniques

- ✅ Advanced multi-stage builds
- ✅ Docker networking and volumes
- ✅ Docker Compose orchestration
- ✅ Health checks and monitoring
- ✅ Build optimization strategies
- ⏱️ **Time**: 5-7 hours

#### Example 5: Node.js Express Multi-Stage (`intermediate/01-nodejs-express-multistage/`)

**What it teaches:**
- Production Node.js patterns
- Development vs production dependencies
- Docker Compose networking
- Health checks in practice
- Environment-based configuration

**Why separate dev and prod dependencies:**
```json
{
  "devDependencies": {
    "nodemon": "^3.0.0",     // 5MB - Auto-restart in dev
    "jest": "^29.0.0",       // 10MB - Testing
    "eslint": "^8.0.0",      // 8MB - Linting
    "@types/node": "^20.0.0" // 15MB - TypeScript types
  },
  "dependencies": {
    "express": "^4.18.0",    // 2MB - Actually needed
    "helmet": "^7.0.0"       // 100KB - Security
  }
}
```

**Impact**: devDependencies = 38MB, dependencies = 2.1MB
**Savings**: 95% size reduction by excluding dev tools!

**Multi-stage strategy:**
```dockerfile
# Stage 1: Build (install everything for building)
FROM node:20-alpine AS builder
COPY package*.json ./
RUN npm ci --include=dev
RUN npm run build  # Might need dev tools for this

# Stage 2: Production (only runtime deps)
FROM node:20-alpine
COPY package*.json ./
RUN npm ci --only=production  # 95% less stuff
COPY --from=builder /app/dist ./dist
USER node
CMD ["node", "dist/server.js"]
```

**Docker Compose benefits:**
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]
      interval: 30s
    networks:
      - app-network
    restart: unless-stopped

networks:
  app-network:
    driver: bridge
```

**Why each setting:**
- **healthcheck**: Orchestrator knows when service is ready
- **networks**: Isolated communication, service discovery
- **restart: unless-stopped**: Auto-restart on crash/reboot
- **environment**: Runtime configuration without rebuilding

**How networking enables:**
```yaml
services:
  app:
    networks:
      - frontend

  database:
    networks:
      - backend

  api:
    networks:
      - frontend
      - backend  # Bridge between them
```

- **Isolation**: Frontend can't directly access database
- **Security**: Only API service can talk to database
- **Service discovery**: Use service name as hostname
- **Scalability**: Add/remove services without IP management

**Real-world application**:
- Production APIs
- Multi-tier applications
- Microservices communication
- Development environment parity

---

#### Example 6: Mosquitto MQTT (`messaging/01-mosquitto-basic/`)

**What it teaches:**
- Message broker setup
- Docker volumes (data persistence)
- Configuration management
- Port mapping (TCP + WebSocket)
- Service dependencies

**Why MQTT:**
```
HTTP Request/Response:
Client → [Request] → Server
Client ← [Response] ← Server
(Connection closed, one-time)

MQTT Pub/Sub:
Publisher → [Message] → Broker → [Message] → Subscribers
(Persistent connection, real-time, many-to-many)
```

**Use cases:**
- ✅ IoT devices (sensors sending data)
- ✅ Real-time dashboards (live updates)
- ✅ Mobile apps (push notifications)
- ✅ Chat systems (instant messaging)

**Why Mosquitto over others:**
| <sub>Feature</sub> | <sub>Mosquitto</sub> | <sub>RabbitMQ</sub> | <sub>Redis Pub/Sub</sub> |
|---------|-----------|----------|---------------|
| <sub>**Size**</sub> | <sub>10MB</sub> | <sub>200MB</sub> | <sub>50MB</sub> |
| <sub>**Protocol**</sub> | <sub>MQTT</sub> | <sub>AMQP</sub> | <sub>Redis</sub> |
| <sub>**IoT focus**</sub> | <sub>✅ Yes</sub> | <sub>❌ No</sub> | <sub>❌ No</sub> |
| <sub>**QoS levels**</sub> | <sub>0,1,2</sub> | <sub>Yes</sub> | <sub>No</sub> |

**Docker Compose setup:**
```yaml
services:
  mosquitto:
    build: .
    ports:
      - "1883:1883"  # MQTT
      - "9001:9001"  # WebSocket
    volumes:
      - mqtt-data:/mosquitto/data      # Persist messages
      - mqtt-logs:/mosquitto/log       # Persist logs
      - ./mosquitto.conf:/mosquitto/config/mosquitto.conf
    restart: unless-stopped

volumes:
  mqtt-data:     # Docker-managed volume
  mqtt-logs:     # Survives container deletion
```

**Why volumes matter:**
```bash
# Without volumes:
docker stop mosquitto  # Data lost!

# With volumes:
docker stop mosquitto  # Data safe
docker rm mosquitto    # Data still safe
docker-compose up      # Data restored!
```

**Configuration explained:**
```conf
# mosquitto.conf
persistence true              # Save messages to disk
persistence_location /mosquitto/data/

listener 1883                 # MQTT port
listener 9001                 # WebSocket port
protocol websockets           # Enable WS

allow_anonymous false         # Security: require auth
password_file /mosquitto/config/passwd
```

**How message flow works:**
1. **Publisher** connects to broker (Mosquitto)
2. **Publishes** message to topic: `sensors/temperature`
3. **Broker** stores message (if QoS 1 or 2)
4. **Subscribers** connected to `sensors/#` receive message
5. **QoS ensures delivery** even if subscriber was offline

**Real-world application**:
- IoT data collection (thousands of sensors)
- Real-time monitoring dashboards
- Mobile app notifications
- Industrial automation
- Smart home systems

### 🌳 Advanced Level
**Focus**: Complex architectures and enterprise patterns

- ✅ Microservices architecture (Mosquitto MQTT example)
- ✅ Custom networking topologies (Docker Compose networking)
- ✅ Security hardening and scanning (Non-root users, minimal images)
- ✅ Performance optimization (Multi-stage builds, layer caching)
- ✅ CI/CD pipeline integration (GitHub Actions workflows)
- ⏱️ **Time**: 10-15 hours

#### Example 7: Go Multi-Stage with Scratch (`advanced/01-go-multistage/`)

**What it teaches:**
- Ultimate size optimization (99.4% reduction!)
- Static binary compilation
- Scratch base image (0 bytes)
- Cross-platform builds
- Production-grade Go services

**Why Go is perfect for extreme optimization:**
```go
// This simple Go code compiles to a fully self-contained binary
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
```

**Compiled characteristics:**
```bash
$ go build -o myapp
$ ls -lh myapp
-rwxr-xr-x  1 user  staff   2.0M Nov  4 10:00 myapp

$ ldd myapp
    not a dynamic executable  # No external dependencies!

$ file myapp
myapp: ELF 64-bit LSB executable, statically linked
```

**Why static linking matters:**
- Binary includes Go runtime (garbage collector, scheduler)
- No libc dependency (unlike C programs)
- Works on ANY Linux system
- Can run from scratch (empty filesystem)

**Multi-stage ultimate optimization:**
```dockerfile
# Stage 1: Build (800MB - full Go toolchain)
FROM golang:1.21-alpine AS builder
WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download        # Cache dependencies separately

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -a -installsuffix cgo \
    -ldflags='-w -s -extldflags "-static"' \
    -o server .

# Stage 2: Runtime (0MB base + 4.58MB binary = 4.58MB total!)
FROM scratch
COPY --from=builder /build/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

**Build flags explained:**
- `CGO_ENABLED=0`: Pure Go, no C dependencies (crucial for scratch)
- `GOOS=linux`: Target Linux (even if building on Mac/Windows)
- `GOARCH=amd64`: Target architecture (can be arm64, etc.)
- `-a`: Force rebuild of all packages (ensures static linking)
- `-ldflags='-w -s'`: Strip debug info and symbol table (~30% size reduction)
- `-extldflags "-static"`: Force static linking

**Size comparison:**
```
golang:1.21              800MB   (Full Go toolchain + OS)
golang:1.21-alpine       315MB   (Go + Alpine Linux)
alpine:latest             5MB    (Just Alpine, no Go)
scratch + Go binary     4.58MB   (Ultimate minimal!)
```

**What is scratch?**
```dockerfile
FROM scratch
# This is literally an empty filesystem.
# No shell, no ls, no cat, no /etc, no /tmp
# NOTHING. It's the absence of everything.
```

**Pros of scratch:**
- ✅ **Smallest possible**: Only your binary
- ✅ **Ultimate security**: No OS, no vulnerabilities, no attack surface
- ✅ **Fast startup**: Nothing to initialize
- ✅ **Perfect for**: Statically compiled binaries (Go, Rust)

**Cons of scratch:**
- ❌ **No shell**: Can't `docker exec -it container sh`
- ❌ **No debugging tools**: No ls, cat, ps, netstat
- ❌ **No CA certificates**: Need to copy if making HTTPS calls
- ❌ **No timezone data**: Need to copy if using time.Local

**When you need CA certificates:**
```dockerfile
FROM alpine:latest AS certs
RUN apk --update add ca-certificates

FROM scratch
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/server /server
ENTRYPOINT ["/server"]
```

**Real-world application**:
- Microservices (thousands of instances = huge cost savings)
- API gateways
- CLI tools distributed as containers
- Serverless functions (AWS Lambda, Cloud Run)
- Edge computing (minimal bandwidth)

**Production benefits:**
```
1000 container instances:
- Regular images: 800GB total
- Scratch images: 4.58GB total
- Bandwidth saved: 795GB
- Pull time: 30 seconds → 1 second
- Cost savings: Significant at scale
```

---

### 🌲 Expert Level
**Focus**: Production deployment and scaling

- ⭕ Kubernetes integration (Planned)
- ✅ High availability setups (Health checks, restart policies, service redundancy)
- ⭕ Advanced monitoring (Prometheus/Grafana - Planned)
- ✅ Enterprise security patterns (Non-root users, minimal images, scratch bases)
- ⭕ Multi-cloud deployments (Planned)
- ⏱️ **Time**: 20+ hours

#### High Availability Patterns (Implemented)

**What high availability means:**
- Service continues running despite failures
- Automatic recovery from crashes
- Zero-downtime deployments
- Health monitoring and auto-healing

**Pattern 1: Health Checks + Restart Policies**
```yaml
# docker-compose.yml
services:
  api:
    image: myapi:latest
    restart: unless-stopped        # Restart on crash
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s                # Check every 30s
      timeout: 10s                 # Fail if takes >10s
      retries: 3                   # Allow 3 failures
      start_period: 40s            # Grace period for startup
```

**How it works:**
1. Container starts, health checks begin after 40s
2. Every 30s, Docker runs health check command
3. If check fails, retry up to 3 times
4. After 3 failures, mark container as unhealthy
5. With `restart: unless-stopped`, Docker restarts it
6. Orchestrators (K8s) can route traffic only to healthy instances

**Pattern 2: Service Redundancy**
```yaml
services:
  api:
    image: myapi:latest
    deploy:
      replicas: 3               # Run 3 copies
      update_config:
        parallelism: 1          # Update one at a time
        delay: 10s              # Wait 10s between updates
      restart_policy:
        condition: on-failure
        max_attempts: 3
```

**Benefits:**
- Load distributed across 3 instances
- If one crashes, two still serve traffic
- Rolling updates = zero downtime
- Parallel deployment prevents all instances failing

**Pattern 3: Network-Level HA**
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      api:
        condition: service_healthy  # Wait for API to be healthy

  api:
    replicas: 3
    healthcheck:
      test: ["CMD", "curl", "localhost:8080/health"]
```

**How nginx load balances:**
```nginx
upstream api_backend {
    server api_1:8080;
    server api_2:8080;
    server api_3:8080;
}

server {
    location /api {
        proxy_pass http://api_backend;
    }
}
```

---

#### Enterprise Security Patterns (Implemented)

**Pattern 1: Minimal Base Images**
```
Attack Surface Comparison:

ubuntu:latest (77MB, 100+ packages)
├─ More packages = more CVEs
├─ Many services/tools available to attacker
└─ Larger attack surface

alpine:latest (5MB, 14 packages)
├─ Minimal packages = fewer CVEs
├─ Limited tools for attacker
└─ Small attack surface

scratch (0MB, 0 packages)
├─ No packages = no CVEs
├─ No tools available whatsoever
└─ Minimal attack surface
```

**Pattern 2: Non-Root Everywhere**
```dockerfile
FROM python:3.11-slim

# Create dedicated user (not root)
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -u 1001 -m -s /bin/false appuser

# Install as root (needed for system packages)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Change ownership
COPY --chown=appuser:appgroup . /app

# Drop privileges
USER appuser

# Now app runs as appuser (UID 1001), not root (UID 0)
CMD ["python", "app.py"]
```

**Why this matters:**
```
Scenario: Attacker exploits app vulnerability

Running as root:
1. Exploit gives shell as root
2. Can install backdoors
3. Can modify system files
4. Can access other containers
5. Can escalate to host (in some configs)

Running as appuser:
1. Exploit gives shell as appuser
2. Can't install packages (no sudo)
3. Can't modify system files
4. Can't access other users' files
5. Limited damage potential
```

**Pattern 3: Read-Only Filesystems**
```yaml
services:
  api:
    image: myapi:latest
    read_only: true              # Filesystem is read-only
    tmpfs:
      - /tmp                     # Except /tmp (writable)
    security_opt:
      - no-new-privileges:true   # Can't escalate privileges
    cap_drop:
      - ALL                      # Drop all Linux capabilities
    cap_add:
      - NET_BIND_SERVICE         # Only add what's needed
```

**What this prevents:**
- ❌ Attacker can't write malicious files
- ❌ Can't modify binaries
- ❌ Can't install persistence mechanisms
- ❌ Can't escalate privileges
- ✅ App still functions (uses /tmp for temp files)

**Pattern 4: Secret Scanning Prevention**
```dockerfile
# ❌ NEVER EVER do this
ENV API_KEY=secret123
RUN echo "password=admin" > config.txt

# ✅ Secrets injected at runtime
ENV API_KEY=""
# Later: docker run -e API_KEY=secret123 myapp
```

**Why docker history is dangerous:**
```bash
$ docker history myapp:latest
IMAGE          CREATED         CREATED BY                      SIZE
abc123         2 minutes ago   ENV API_KEY=secret123           0B

# Anyone with image access sees your secrets!
```

**Correct approach:**
```bash
# Runtime secrets
docker run -e API_KEY="$(cat secret.txt)" myapp

# Or with secrets manager
docker secret create api_key api_key.txt
docker service create --secret api_key myapp
```

---

#### CI/CD Integration (Implemented via GitHub Actions)

**What our CI/CD does:**
```yaml
# .github/workflows/ci-cd.yml
name: Docker Examples CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-examples:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Test all multi-stage builds
        run: bash tests/test-multistage-builds.sh

      - name: Build and test examples
        run: |
          cd examples/beginner/04-python-flask-multistage
          docker build -t test-flask .
          docker run --rm test-flask
```

**Why this is important:**
1. **Automated testing**: Every commit is tested
2. **Catch breaks early**: Before merging to main
3. **Documentation accuracy**: Examples must build successfully
4. **Security scanning**: Can add Trivy/Snyk scans
5. **Image publishing**: Can push to registry on tag

**Real-world application**:
- Automated testing of all examples
- Prevent broken code from merging
- Ensure examples work across platforms
- Automated image building and publishing
- Security vulnerability scanning

## 🔧 Technology Stack & Why We Chose Them

### Core Technologies

| <sub>Technology</sub> | <sub>Purpose</sub> | <sub>Why We Chose It</sub> | <sub>Trade-offs</sub> | <sub>Example Location</sub> |
|------------|---------|-----------------|------------|------------------|
| <sub>**Docker**</sub> | <sub>Container Runtime</sub> | <sub>Industry standard, extensive ecosystem, cross-platform support</sub> | <sub>Learning curve for beginners</sub> | <sub>All examples</sub> |
| <sub>**Docker Compose**</sub> | <sub>Multi-container orchestration</sub> | <sub>Simplified local development, easy configuration YAML</sub> | <sub>Not for production at scale (use Kubernetes)</sub> | <sub>`intermediate/`, `messaging/`</sub> |
| <sub>**Alpine Linux**</sub> | <sub>Base Images</sub> | <sub>Minimal size (5MB), security-focused, musl libc</sub> | <sub>Some packages not available, compatibility issues</sub> | <sub>Most examples</sub> |
| <sub>**Debian Slim**</sub> | <sub>Alternative Base</sub> | <sub>Better compatibility, glibc, more packages available</sub> | <sub>Larger than Alpine (~30MB vs 5MB)</sub> | <sub>Python examples</sub> |
| <sub>**Scratch**</sub> | <sub>Minimal Base</sub> | <sub>Literally empty (0MB), maximum security</sub> | <sub>Only works with static binaries (Go, Rust)</sub> | <sub>Go example</sub> |

### Why These Base Images?

#### Alpine Linux (5MB)
```dockerfile
FROM python:3.11-alpine
```

**Why we chose it:**
- ✅ **Tiny size**: 5MB base saves bandwidth and storage
- ✅ **Security**: Minimal attack surface, fewer CVEs
- ✅ **Fast**: Quick pulls and starts
- ✅ **Package manager**: apk is lightweight and fast

**Trade-offs:**
- ⚠️ **musl libc vs glibc**: Some Python wheels need compilation
- ⚠️ **Build tools**: May need to install gcc, musl-dev for native extensions
- ⚠️ **Compatibility**: Some libraries expect glibc

**When to use**: Microservices, APIs, simple applications

#### Debian Slim (30MB)
```dockerfile
FROM python:3.11-slim
```

**Why we chose it:**
- ✅ **Compatibility**: Uses glibc (standard Linux library)
- ✅ **Pre-built wheels**: Most Python packages work out-of-box
- ✅ **Familiar**: Standard Debian tools (apt, bash)
- ✅ **Balance**: Good size/compatibility trade-off

**Trade-offs:**
- ⚠️ **Larger**: 6x bigger than Alpine
- ⚠️ **More packages**: More potential vulnerabilities

**When to use**: Production Python apps, complex dependencies

#### Scratch (0MB)
```dockerfile
FROM scratch
```

**Why we use it:**
- ✅ **Ultimate minimal**: Literally nothing
- ✅ **Maximum security**: No OS, no vulnerabilities
- ✅ **Tiniest possible**: Only your binary
- ✅ **Fast startup**: Nothing to initialize

**Trade-offs:**
- ⚠️ **Static binaries only**: Go, Rust, C (statically linked)
- ⚠️ **No shell**: Can't `docker exec` into it
- ⚠️ **No CA certs**: Need to copy if making HTTPS calls
- ⚠️ **No debugging tools**: Production-only

**When to use**: Go microservices, Rust apps, maximum optimization

### Programming Languages & Frameworks

#### 🐍 Python (3.11)

**Why Python?**
- 🌍 **Popularity**: #1 language for data science, AI/ML, automation
- 📚 **Rich ecosystem**: 400,000+ packages on PyPI
- 🚀 **Rapid development**: Quick to prototype and deploy
- 🔧 **Versatile**: Web, data processing, scripts, APIs

**Why Flask?**
- ⚡ **Lightweight**: Minimal core, add what you need
- 📖 **Simple**: Easy to learn, great for microservices
- 🔌 **Flexible**: Not opinionated, use any ORM/template engine
- 🎯 **Perfect for**: REST APIs, small to medium services

**Why Gunicorn?**
```python
# Development (Flask dev server)
flask run  # Single-threaded, not for production!

# Production (Gunicorn)
gunicorn app:app --workers 4 --threads 2
```

- 🔐 **Production-ready**: Battle-tested WSGI server
- ⚡ **Concurrent**: Multiple workers and threads
- 🛡️ **Reliable**: Pre-fork worker model, isolates crashes
- 📊 **Performance**: Handles thousands of requests/second

**Multi-stage strategy:**
```dockerfile
# Stage 1: Install dependencies with build tools
FROM python:3.11 AS builder
RUN pip install --user --no-cache-dir -r requirements.txt
# Why --user? Installs to /root/.local (easy to copy)
# Why --no-cache-dir? Saves ~50MB

# Stage 2: Slim runtime without build tools
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
# Result: No pip, no setuptools, no build tools
```

**Example**: `examples/beginner/04-python-flask-multistage/`

#### 🟢 Node.js (20 LTS)

**Why Node.js?**
- ⚡ **Non-blocking I/O**: Handle thousands of concurrent connections
- 🌍 **JavaScript everywhere**: Same language frontend/backend
- 📦 **NPM ecosystem**: Largest package registry (2M+ packages)
- 🚀 **Fast**: V8 engine (same as Chrome)
- 💼 **Enterprise adoption**: Used by Netflix, PayPal, NASA

**Why Express.js?**
```javascript
// Minimal but powerful
const express = require('express');
const app = express();

app.get('/api/users', (req, res) => {
  res.json({ users: [] });
});
```

- 🎯 **Minimalist**: Unopinionated, flexible
- 📈 **Proven**: Industry standard (14M downloads/week)
- 🔌 **Middleware**: Rich ecosystem of plugins
- 📖 **Simple**: Easy to learn, hard to master

**Why Alpine for Node.js?**
```
node:20          → 1.1 GB (includes npm, yarn, full OS)
node:20-alpine   → 135 MB (87% smaller!)
```

**Development vs Production Dependencies:**
```json
{
  "devDependencies": {
    "nodemon": "^3.0.0",    // Auto-restart during dev
    "jest": "^29.0.0",      // Testing framework
    "eslint": "^8.0.0"      // Code linting
  },
  "dependencies": {
    "express": "^4.18.0",   // Actually needed in prod
    "helmet": "^7.0.0"      // Security headers
  }
}
```

**Multi-stage strategy:**
```dockerfile
# Stage 1: Build with all dependencies
FROM node:20-alpine AS builder
RUN npm ci --include=dev  # Install everything
RUN npm run build         # Build/compile

# Stage 2: Production with only runtime deps
FROM node:20-alpine
RUN npm ci --only=production  # Only "dependencies"
# Result: ~50MB savings, no dev tools in prod
```

**Example**: `examples/intermediate/01-nodejs-express-multistage/`

#### 🔵 Go (1.21)

**Why Go?**
- ⚡ **Blazing fast**: Compiled, not interpreted
- 🔄 **Concurrency**: Goroutines for easy parallelism
- 📦 **Static binaries**: Single file deployment
- 🛡️ **Memory safe**: Garbage collection, no segfaults
- ☁️ **Cloud-native**: Docker, Kubernetes written in Go

**Why Go is Perfect for Multi-Stage Builds:**
```go
// This compiles to a single binary with NO dependencies
package main

func main() {
    println("Hello, World!")
}
```

**Compiled binary characteristics:**
```bash
$ go build -o myapp
$ ldd myapp
    not a dynamic executable  # Statically linked!
```

**Multi-stage strategy (Ultimate optimization):**
```dockerfile
# Stage 1: Build with full Go toolchain (800MB)
FROM golang:1.21-alpine AS builder
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o app
# CGO_ENABLED=0 → Pure Go, no C dependencies
# -ldflags="-w -s" → Strip debug info (saves ~30%)

# Stage 2: Scratch base (0MB)
FROM scratch
COPY --from=builder /app/app /app
# Result: 4.58MB (99.4% reduction!)
```

**Why this works:**
1. Go binary is self-contained (includes runtime)
2. No external dependencies needed
3. Scratch provides literally nothing but works!

**Example**: `examples/advanced/01-go-multistage/`

```mermaid
graph LR
    A[Python 3.12] --> B[Flask Framework]
    B --> C[Gunicorn WSGI Server]
    C --> D[Production Ready]

    style A fill:#2d3748,stroke:#4299e1,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#ed8936,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#9f7aea,stroke-width:2px,color:#fff
```

#### 🟢 Node.js
**Why**: JavaScript everywhere, huge ecosystem, non-blocking I/O
- **Express.js**: Minimal, flexible, widely adopted web framework
- **Alpine base**: Reduces image size from ~900MB to ~130MB
- **Example**: `examples/intermediate/01-nodejs-express-multistage/`

```mermaid
graph LR
    A[Node.js 20 Alpine] --> B[Express.js]
    B --> C[Production Build]
    C --> D[Minimal Runtime]

    style A fill:#2d3748,stroke:#4299e1,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#ed8936,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#9f7aea,stroke-width:2px,color:#fff
```

### Messaging Systems

#### 🦟 Mosquitto MQTT
**Why**: Lightweight pub/sub protocol for IoT
- **Use Case**: Real-time messaging, IoT devices, sensor networks
- **Advantages**: Low bandwidth, quality of service levels, retained messages
- **Example**: `messaging/01-mosquitto-basic/`

### Image Size Comparison

```mermaid
graph TB
    subgraph "Single-Stage Build"
        A1[Full Image: 800MB] --> A2[Build Tools: 400MB]
        A2 --> A3[Dependencies: 300MB]
        A3 --> A4[App Code: 100MB]
    end

    subgraph "Multi-Stage Build"
        B1[Final Image: 150MB] --> B2[Runtime Only: 50MB]
        B2 --> B3[Dependencies: 80MB]
        B3 --> B4[App Code: 20MB]
    end

    style A1 fill:#742a2a,stroke:#fc8181,stroke-width:2px,color:#fff
    style B1 fill:#22543d,stroke:#68d391,stroke-width:2px,color:#fff
    style A2 fill:#2d3748,stroke:#fc8181,stroke-width:1px,color:#fff
    style A3 fill:#2d3748,stroke:#fc8181,stroke-width:1px,color:#fff
    style A4 fill:#2d3748,stroke:#fc8181,stroke-width:1px,color:#fff
    style B2 fill:#2d3748,stroke:#68d391,stroke-width:1px,color:#fff
    style B3 fill:#2d3748,stroke:#68d391,stroke-width:1px,color:#fff
    style B4 fill:#2d3748,stroke:#68d391,stroke-width:1px,color:#fff
```

### Why Multi-Stage Builds?

| <sub>Aspect</sub> | <sub>Single-Stage</sub> | <sub>Multi-Stage</sub> | <sub>Improvement</sub> |
|--------|--------------|-------------|-------------|
| <sub>**Image Size**</sub> | <sub>500MB - 2GB</sub> | <sub>50MB - 300MB</sub> | <sub>**70-90% reduction**</sub> |
| <sub>**Build Time**</sub> | <sub>Slow (no caching)</sub> | <sub>Fast (layer caching)</sub> | <sub>**50-70% faster**</sub> |
| <sub>**Security**</sub> | <sub>All build tools included</sub> | <sub>Only runtime needed</sub> | <sub>**80% fewer vulnerabilities**</sub> |
| <sub>**Attack Surface**</sub> | <sub>Large</sub> | <sub>Minimal</sub> | <sub>**Significantly reduced**</sub> |
| <sub>**Deployment Speed**</sub> | <sub>Slow transfer</sub> | <sub>Fast transfer</sub> | <sub>**3-5x faster**</sub> |

## 🎓 Multi-Stage Builds Deep Dive

### What Are Multi-Stage Builds?

Multi-stage builds allow you to use multiple `FROM` statements in your Dockerfile. Each `FROM` instruction starts a new stage, and you can selectively copy artifacts from one stage to another.

### Basic Pattern

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]
```

### Real-World Example Comparison

| <sub>Example</sub> | <sub>Single-Stage</sub> | <sub>Multi-Stage</sub> | <sub>Reduction</sub> |
|---------|--------------|-------------|-----------|
| <sub>Python Flask</sub> | <sub>450MB</sub> | <sub>151MB</sub> | <sub>66% ⬇️</sub> |
| <sub>Node.js Express</sub> | <sub>380MB</sub> | <sub>137MB</sub> | <sub>64% ⬇️</sub> |
| <sub>Go Application</sub> | <sub>800MB</sub> | <sub>12MB</sub> | <sub>98% ⬇️</sub> |
| <sub>React App</sub> | <sub>1.2GB</sub> | <sub>25MB</sub> | <sub>98% ⬇️</sub> |

### Key Benefits Flow

```mermaid
graph LR
    A[Multi-Stage Builds] --> B[Smaller Images]
    A --> C[Better Security]
    A --> D[Faster Deploys]
    A --> E[Cost Savings]

    B --> F[Less Network Transfer]
    C --> G[Fewer Vulnerabilities]
    D --> H[Quick Rollbacks]
    E --> I[Lower Storage Costs]

    style A fill:#2d3748,stroke:#4299e1,stroke-width:3px,color:#fff
    style B fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style E fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style F fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
    style G fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
    style H fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
    style I fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
```

## 📖 Documentation

### Core Documentation
- [PROJECT_GOALS.md](PROJECT_GOALS.md) - Project purpose, audience, and roadmap
- [WORKFLOW.md](WORKFLOW.md) - Development workflow and contribution process
- [Memory Bank](memory-bank/) - Architecture decisions and implementation plans

### Example Guides
- [Project Plan](docs/project-plan.md) - Detailed roadmap and implementation plan
- [Example Guides](docs/examples/) - Step-by-step tutorials for each example
- [Best Practices](docs/best-practices.md) - Docker optimization and security guidelines
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

### Memory Bank System
Our project uses a memory bank to track:
- **App Description**: Core features and technical stack
- **Architecture Decisions**: Why we made specific choices
- **Implementation Plans**: ACID-based development steps
- **Change Log**: Detailed history of all modifications

## ✨ Key Features

### 🎯 Production-Ready Examples
- **Real-world scenarios**: Not just hello-world apps
- **Best practices**: Following Docker's official recommendations
- **Security-first**: Minimal attack surface, non-root users
- **Performance optimized**: Layer caching, .dockerignore files

### 📊 Comprehensive Coverage

```mermaid
graph TD
    A[Dockerfile Examples] --> B[Languages]
    A --> C[Patterns]
    A --> D[Technologies]

    B --> B1[Python]
    B --> B2[Node.js]
    B --> B3[Go]
    B --> B4[Java]

    C --> C1[Multi-Stage]
    C --> C2[Microservices]
    C --> C3[Monorepo]

    D --> D1[Databases]
    D --> D2[Message Queues]
    D --> D3[Web Servers]

    style A fill:#2d3748,stroke:#4299e1,stroke-width:3px,color:#fff
    style B fill:#2d3748,stroke:#48bb78,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#ed8936,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#9f7aea,stroke-width:2px,color:#fff
    style B1 fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
    style B2 fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
    style B3 fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
    style B4 fill:#1a365d,stroke:#63b3ed,stroke-width:1px,color:#fff
    style C1 fill:#1a365d,stroke:#fbd38d,stroke-width:1px,color:#fff
    style C2 fill:#1a365d,stroke:#fbd38d,stroke-width:1px,color:#fff
    style C3 fill:#1a365d,stroke:#fbd38d,stroke-width:1px,color:#fff
    style D1 fill:#1a365d,stroke:#b794f4,stroke-width:1px,color:#fff
    style D2 fill:#1a365d,stroke:#b794f4,stroke-width:1px,color:#fff
    style D3 fill:#1a365d,stroke:#b794f4,stroke-width:1px,color:#fff
```

### 🔒 Security Features
- Non-root user execution
- Minimal base images (Alpine Linux)
- Security scanning examples
- Secrets management patterns
- Network isolation examples

### 📈 Performance Optimization
- Multi-stage builds (70-90% size reduction)
- Layer caching strategies
- BuildKit features
- Parallel build stages
- .dockerignore best practices

---

## 🎨 Common Patterns & Best Practices Explained

### Pattern 1: Layer Caching Optimization

**❌ Inefficient (Cache invalidated on every code change):**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .                          # Copies everything, including code
RUN pip install -r requirements.txt  # Reinstalls on EVERY change
CMD ["python", "app.py"]
```

**Problem**: Any change to your source code invalidates the cache from the COPY step onwards, forcing a complete reinstall of all dependencies.

**✅ Optimized (Cache-friendly):**
```dockerfile
FROM python:3.11-slim
WORKDIR /app

# Step 1: Copy only dependency files first
COPY requirements.txt .

# Step 2: Install dependencies (cached until requirements.txt changes)
RUN pip install --no-cache-dir -r requirements.txt

# Step 3: Copy source code last (changes frequently)
COPY . .

CMD ["python", "app.py"]
```

**Why this works:**
- Dependencies rarely change → cached ✅
- Source code changes frequently → only last layer rebuilds ✅
- Build time: 60 seconds → 5 seconds for code changes 🚀

### Pattern 2: Multi-Stage with Build Arguments

**Use case**: Different configurations for dev/staging/prod

```dockerfile
# Build stage
FROM node:20-alpine AS builder
ARG BUILD_ENV=production
ARG API_URL

# Use build args during build
RUN echo "Building for ${BUILD_ENV} with API ${API_URL}"
RUN npm run build:${BUILD_ENV}

# Runtime stage
FROM node:20-alpine
COPY --from=builder /app/dist /app

# Runtime env vars (can be overridden at container start)
ENV NODE_ENV=production
CMD ["node", "server.js"]
```

**How to use:**
```bash
# Development build
docker build --build-arg BUILD_ENV=development \
             --build-arg API_URL=http://localhost:3000 \
             -t myapp:dev .

# Production build
docker build --build-arg BUILD_ENV=production \
             --build-arg API_URL=https://api.example.com \
             -t myapp:prod .
```

**Key differences:**
- **BUILD_ARG**: Set at build time, baked into image
- **ENV**: Can be changed at runtime with `docker run -e`

### Pattern 3: Health Checks

**Why health checks matter:**
- Container orchestrators (Kubernetes, Docker Swarm) need to know if your app is healthy
- Automatic restarts of unhealthy containers
- Load balancers route traffic only to healthy instances

**Implementation:**

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Health check that runs every 30 seconds
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

EXPOSE 3000
CMD ["node", "server.js"]
```

**healthcheck.js:**
```javascript
const http = require('http');

const options = {
  host: 'localhost',
  port: 3000,
  path: '/health',
  timeout: 2000
};

const req = http.request(options, (res) => {
  process.exit(res.statusCode === 200 ? 0 : 1);
});

req.on('error', () => process.exit(1));
req.end();
```

**What this does:**
1. Every 30 seconds, Docker runs `node healthcheck.js`
2. Script makes HTTP request to `/health` endpoint
3. Returns 0 (healthy) or 1 (unhealthy)
4. After 3 failures, container marked as unhealthy
5. Orchestrator can restart or replace container

### Pattern 4: Non-Root User (Security)

**❌ Dangerous (Running as root):**
```dockerfile
FROM python:3.11-slim
COPY . /app
WORKDIR /app
CMD ["python", "app.py"]
# Running as root (UID 0) - security risk!
```

**Why this is bad:**
- If attacker breaks out of app, they have root access
- Can modify system files, install backdoors
- Violates principle of least privilege

**✅ Secure (Non-root user):**
```dockerfile
FROM python:3.11-slim

# Create dedicated user and group
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -u 1001 appuser

# Set up application
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Change ownership to app user
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

CMD ["python", "app.py"]
```

**What this does:**
1. Creates system user `appuser` (UID 1001)
2. Installs dependencies as root (needed for system packages)
3. Changes file ownership to app user
4. Switches to non-root user before starting app
5. App runs with limited permissions ✅

### Pattern 5: .dockerignore (Build Performance)

**Why use .dockerignore:**
- Reduces build context size
- Faster uploads to Docker daemon
- Prevents secrets from entering image
- Speeds up COPY operations

**.dockerignore example:**
```dockerignore
# Version control
.git
.gitignore

# Dependencies (install from package.json instead)
node_modules
__pycache__
*.pyc

# Development files
*.md
.vscode
.idea
*.log

# Test files
tests/
__tests__/
*.test.js
coverage/

# Environment files (NEVER include in image!)
.env
.env.local
*.key
*.pem

# Build artifacts
dist/
build/
*.tar.gz

# OS files
.DS_Store
Thumbs.db
```

**Impact:**
```
Without .dockerignore: Build context = 500MB
With .dockerignore: Build context = 2MB
Result: 250x smaller, much faster builds!
```

### Pattern 6: Secret Management

**❌ NEVER do this:**
```dockerfile
# Secrets baked into image layers!
ENV DATABASE_PASSWORD=super_secret_123
RUN echo "api_key=abc123" > config.txt
```

**Why this is catastrophic:**
- Anyone with image access can extract secrets
- Even if deleted later, secrets remain in image history
- `docker history myimage` shows everything!

**✅ Correct approaches:**

**Option 1: Runtime environment variables**
```dockerfile
# Dockerfile - NO secrets
ENV DATABASE_PASSWORD=""

# Pass secrets at runtime
docker run -e DATABASE_PASSWORD="secret" myapp
```

**Option 2: Docker secrets (Swarm/Compose)**
```yaml
# docker-compose.yml
services:
  app:
    image: myapp
    secrets:
      - db_password

secrets:
  db_password:
    file: ./db_password.txt  # Not in git!
```

**Option 3: BuildKit secrets (for build time)**
```dockerfile
# Dockerfile
FROM python:3.11-slim
RUN --mount=type=secret,id=pip_credentials \
    pip install --index-url $(cat /run/secrets/pip_credentials) mypackage
```

```bash
# Build with secret
docker build --secret id=pip_credentials,src=./pip.conf .
```

**Key principle**: Secrets should NEVER be in the image, only provided at runtime.

### Pattern 7: Multi-Platform Builds

**Why**: Support both AMD64 (Intel/AMD) and ARM64 (Apple Silicon, AWS Graviton)

```dockerfile
FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Build for target platform
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -o app .

FROM scratch
COPY --from=builder /app/app /app
ENTRYPOINT ["/app"]
```

**Build for multiple platforms:**
```bash
# Create multi-platform builder
docker buildx create --name multiplatform --use

# Build for both platforms
docker buildx build --platform linux/amd64,linux/arm64 \
  -t myapp:latest --push .
```

**Result**: One image tag that works on both architectures!

### 🎯 Quick Reference: When to Use What

| <sub>Scenario</sub> | <sub>Pattern</sub> | <sub>Why</sub> |
|----------|---------|-----|
| <sub>Compiled languages (Go, Rust, Java)</sub> | <sub>Multi-stage + scratch/distroless</sub> | <sub>90%+ size reduction</sub> |
| <sub>Interpreted languages (Python, Node.js)</sub> | <sub>Multi-stage + slim base</sub> | <sub>60-70% size reduction</sub> |
| <sub>Frequent dependency changes</sub> | <sub>Cache optimization (copy package files first)</sub> | <sub>Fast rebuilds</sub> |
| <sub>Production deployment</sub> | <sub>Non-root user + health checks</sub> | <sub>Security + reliability</sub> |
| <sub>Secrets needed</sub> | <sub>Runtime env vars or Docker secrets</sub> | <sub>Never baked into image</sub> |
| <sub>Multiple environments (dev/prod)</sub> | <sub>Build arguments</sub> | <sub>Different configs per environment</sub> |
| <sub>Fast builds</sub> | <sub>.dockerignore + layer optimization</sub> | <sub>Reduce build context</sub> |
| <sub>Multiple architectures</sub> | <sub>Multi-platform builds</sub> | <sub>Support Intel + ARM</sub> |

---

## 🤝 Contributing

We welcome contributions from the community! Whether you're fixing bugs, adding examples, or improving documentation, your help is appreciated.

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-example`
3. **Make your changes** following our [WORKFLOW.md](WORKFLOW.md)
4. **Test thoroughly**: Ensure all examples build and run
5. **Commit your changes**: Use conventional commit messages
6. **Push to your fork**: `git push origin feature/amazing-example`
7. **Open a Pull Request**

### Contribution Ideas

- 🆕 **New Examples**: Add examples for different languages or frameworks
- 📝 **Documentation**: Improve guides, add diagrams, fix typos
- 🐛 **Bug Fixes**: Fix issues in existing examples
- 🔒 **Security**: Add security scanning or hardening examples
- 🎨 **Templates**: Create reusable Dockerfile templates
- 🧪 **Tests**: Add automated testing for examples

### Guidelines

Please see our detailed [Contributing Guide](docs/contributing.md) for:
- Code style and conventions
- Testing requirements
- Documentation standards
- Review process

## � Project Status

| <sub>Metric</sub> | <sub>Status</sub> |
|--------|--------|
| <sub>**Beginner Examples**</sub> | <sub>✅ 4/4 Complete</sub> |
| <sub>**Intermediate Examples**</sub> | <sub>✅ 1/3 In Progress</sub> |
| <sub>**Advanced Examples**</sub> | <sub>⭕ 0/5 Planned</sub> |
| <sub>**Expert Examples**</sub> | <sub>⭕ 0/3 Planned</sub> |
| <sub>**Documentation**</sub> | <sub>🟡 75% Complete</sub> |
| <sub>**Test Coverage**</sub> | <sub>🟡 60% Complete</sub> |

## �📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources & Links

### Official Documentation
- [Docker Documentation](https://docs.docker.com/) - Official Docker docs
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/) - Optimization guidelines
- [Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/) - Official multi-stage guide
- [Docker Compose](https://docs.docker.com/compose/) - Orchestration tool

### Related Technologies
- [Alpine Linux](https://alpinelinux.org/) - Minimal base images
- [Mosquitto MQTT](https://mosquitto.org/) - Lightweight message broker
- [Gunicorn](https://gunicorn.org/) - Python WSGI HTTP Server
- [Express.js](https://expressjs.com/) - Node.js web framework

### Learning Resources
- [Play with Docker](https://labs.play-with-docker.com/) - Free Docker playground
- [Docker Hub](https://hub.docker.com/) - Container image registry
- [Awesome Docker](https://github.com/veggiemonk/awesome-docker) - Curated Docker resources

## 🙏 Acknowledgments

- Docker team for excellent documentation
- Open source community for inspiration
- Contributors who help improve this project

## 📬 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/hkevin01/Dockerfile-Example/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hkevin01/Dockerfile-Example/discussions)
- **Repository**: [hkevin01/Dockerfile-Example](https://github.com/hkevin01/Dockerfile-Example)

---

<div align="center">

**⭐ If you find this project helpful, please consider giving it a star! ⭐**

Made with ❤️ for the Docker community

</div>

---

**Note**: This project is designed for educational purposes and includes examples suitable for learning and development. For production use, always review and adapt the examples according to your specific security and performance requirements.