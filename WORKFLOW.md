# Development Workflow

## Overview
This document outlines the development workflow for the Dockerfile-Example project.

## Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature development branches
- `fix/*` - Bug fix branches

## Development Process

### 1. Starting New Work
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### 2. Making Changes
- Make small, atomic commits
- Test each Docker example locally
- Ensure documentation is updated

### 3. Testing
```bash
# Test individual examples
cd examples/beginner/01-hello-world
docker build -t test-image .

# Run comprehensive tests
./scripts/build-and-test.sh
```

### 4. Committing Changes
```bash
git add .
git commit -m "feat: add new multi-stage example"
git push origin feature/your-feature-name
```

## Commit Message Convention
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## Code Review Process
1. Create pull request to `develop`
2. Ensure all tests pass
3. Request review from maintainers
4. Address feedback
5. Merge when approved

## Release Process
1. Merge `develop` to `main`
2. Tag release with version
3. Update CHANGELOG.md
4. Deploy documentation
