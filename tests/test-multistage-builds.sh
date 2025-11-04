#!/bin/bash
# Test script for multi-stage Docker builds

echo "🧪 Testing Multi-Stage Docker Builds"
echo "===================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0
ORIGINAL_DIR=$(pwd)

# Test function
test_build() {
    local name=$1
    local path=$2
    local image=$3

    echo -e "\n${YELLOW}Testing: ${name}${NC}"
    echo "Path: $path"

    if [ ! -d "$path" ]; then
        echo -e "${RED}❌ FAILED${NC} - Directory not found: $path"
        ((FAILED++))
        return
    fi

    cd "$path" || return 1

    if docker build -t "$image" . > /dev/null 2>&1; then
        SIZE=$(docker images "$image" --format "{{.Size}}")
        echo -e "${GREEN}✅ PASSED${NC} - Image: $image, Size: $SIZE"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC} - Build failed for $image"
        ((FAILED++))
    fi

    cd "$ORIGINAL_DIR" || exit 1
}

# Test cases
BASE_DIR="/home/kevin/Projects/dockerfile-example"

test_build "Python Flask Multi-Stage" \
    "$BASE_DIR/examples/beginner/04-python-flask-multistage" \
    "test-flask-multistage"

test_build "Node.js Express Multi-Stage" \
    "$BASE_DIR/examples/intermediate/01-nodejs-express-multistage" \
    "test-nodejs-multistage"

test_build "Go Multi-Stage (Scratch)" \
    "$BASE_DIR/examples/advanced/01-go-multistage" \
    "test-go-multistage"

test_build "Mosquitto MQTT" \
    "$BASE_DIR/messaging/01-mosquitto-basic" \
    "test-mosquitto"

# Summary
echo -e "\n===================================="
echo -e "Test Results:"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed${NC}"
    exit 1
fi
