# Tests

This directory contains automated tests for the Dockerfile examples.

## Test Scripts

### test-multistage-builds.sh
Tests all multi-stage build examples to ensure they build successfully.

**Usage:**
```bash
./tests/test-multistage-builds.sh
```

**What it tests:**
- Python Flask multi-stage build
- Node.js Express multi-stage build
- Mosquitto MQTT container
- Reports image sizes for each build

## Running Tests

### Run all tests
```bash
./tests/test-multistage-builds.sh
```

### Run specific example test
```bash
cd examples/beginner/04-python-flask-multistage
docker build -t test-flask .
docker run -p 5000:5000 test-flask
curl http://localhost:5000
```

## CI/CD Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Test Multi-Stage Builds
  run: ./tests/test-multistage-builds.sh
```

## Adding New Tests

1. Create a new test script in this directory
2. Make it executable: `chmod +x test-name.sh`
3. Follow the existing pattern for consistency
4. Update this README with test description
