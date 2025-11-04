#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Multi-Stage Build vs Single-Stage Comparison${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Build multi-stage image
echo -e "${YELLOW}Building multi-stage image...${NC}"
docker build -t flask-multistage:latest . > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Multi-stage build successful${NC}"
else
    echo -e "${RED}✗ Multi-stage build failed${NC}"
    exit 1
fi

# Create single-stage Dockerfile for comparison
cat > Dockerfile.single << 'DOCKERFILE'
# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /app

# Install ALL dependencies (including build tools)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
DOCKERFILE

# Build single-stage image
echo -e "${YELLOW}Building single-stage image for comparison...${NC}"
docker build -f Dockerfile.single -t flask-singlestage:latest . > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Single-stage build successful${NC}"
else
    echo -e "${RED}✗ Single-stage build failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Image Size Comparison${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Get image sizes
MULTI_SIZE=$(docker images flask-multistage:latest --format "{{.Size}}")
SINGLE_SIZE=$(docker images flask-singlestage:latest --format "{{.Size}}")

echo -e "Single-Stage Build:    ${RED}$SINGLE_SIZE${NC}"
echo -e "Multi-Stage Build:     ${GREEN}$MULTI_SIZE${NC}"
echo ""

# Calculate approximate savings
MULTI_MB=$(docker images flask-multistage:latest --format "{{.Size}}" | sed 's/MB//')
SINGLE_MB=$(docker images flask-singlestage:latest --format "{{.Size}}" | sed 's/MB//')

if [[ "$MULTI_MB" =~ ^[0-9.]+$ ]] && [[ "$SINGLE_MB" =~ ^[0-9.]+$ ]]; then
    SAVINGS=$(echo "scale=1; $SINGLE_MB - $MULTI_MB" | bc)
    PERCENT=$(echo "scale=1; ($SAVINGS / $SINGLE_MB) * 100" | bc)
    echo -e "Space Saved:           ${GREEN}~${SAVINGS}MB (${PERCENT}%)${NC}"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Image Layers Comparison${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Single-Stage Layers:${NC}"
docker history flask-singlestage:latest --no-trunc --format "table {{.Size}}\t{{.CreatedBy}}" | head -10

echo ""
echo -e "${YELLOW}Multi-Stage Layers (final image only):${NC}"
docker history flask-multistage:latest --no-trunc --format "table {{.Size}}\t{{.CreatedBy}}" | head -10

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Key Differences${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}✓${NC} Multi-stage build excludes build dependencies (gcc, python3-dev)"
echo -e "${GREEN}✓${NC} Multi-stage build has smaller attack surface"
echo -e "${GREEN}✓${NC} Multi-stage build downloads and deploys faster"
echo -e "${GREEN}✓${NC} Multi-stage build follows production best practices"
echo ""

# Cleanup
rm Dockerfile.single

echo -e "${YELLOW}Tip: Run these containers to verify they both work:${NC}"
echo -e "  docker run -p 5000:5000 flask-multistage:latest"
echo -e "  docker run -p 5001:5000 flask-singlestage:latest"
echo ""
