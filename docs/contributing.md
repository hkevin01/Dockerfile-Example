# Contributing to Dockerfile Examples

Thank you for your interest in contributing to the Dockerfile Examples project! This guide will help you get started with contributing to our repository.

## 🎯 Ways to Contribute

### 1. Add New Examples
- Create new Dockerfile examples for different technologies
- Improve existing examples with better practices
- Add examples for new use cases or scenarios

### 2. Improve Documentation
- Fix typos or improve clarity
- Add more detailed explanations
- Create tutorials or guides
- Translate documentation

### 3. Report Issues
- Bug reports for non-working examples
- Suggestions for improvements
- Security vulnerability reports
- Performance issues

### 4. Code Review
- Review pull requests
- Test new examples
- Provide feedback on implementations

## 📋 Getting Started

### Prerequisites
- Docker installed and running
- Git configured
- Basic understanding of Docker concepts
- Familiarity with the technologies you're working with

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Go to GitHub and fork the repository
   # Then clone your fork
   git clone git@github.com:YOUR_USERNAME/Dockerfile-Example.git
   cd Dockerfile-Example
   ```

2. **Set up upstream remote**
   ```bash
   git remote add upstream git@github.com:hkevin01/Dockerfile-Example.git
   ```

3. **Create a new branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📝 Example Structure Guidelines

### Directory Naming
- Use descriptive, kebab-case names
- Include difficulty level prefix (e.g., `01-hello-world`)
- Group related examples in subdirectories

### Required Files for Each Example
```
example-name/
├── Dockerfile              # Main Dockerfile
├── README.md               # Example documentation
├── docker-compose.yml      # If applicable
├── .dockerignore          # If needed
├── src/                   # Application source code
└── scripts/               # Helper scripts
```

### README.md Template for Examples
```markdown
# Example Name

Brief description of what this example demonstrates.

## What You'll Learn
- Concept 1
- Concept 2
- Concept 3

## Prerequisites
- List any requirements

## Quick Start
```bash
# Build the image
docker build -t example-name .

# Run the container
docker run -p 8080:8080 example-name
```

## Explanation
Detailed explanation of the Dockerfile and concepts.

## Testing
How to test that the example works correctly.

## Next Steps
Links to related examples or concepts.
```

## 🔧 Development Guidelines

### Dockerfile Standards
- Follow [Docker best practices](docs/best-practices.md)
- Include helpful comments
- Use appropriate base images
- Optimize for size and security

### Code Quality
- Test all examples before submitting
- Ensure examples work on multiple platforms
- Use consistent formatting and style
- Include error handling where appropriate

### Documentation
- Write clear, concise explanations
- Include working code examples
- Add troubleshooting sections
- Use proper markdown formatting

## 🧪 Testing Your Contributions

### Local Testing
1. **Build and test your example**
   ```bash
   cd your-example-directory
   docker build -t test-example .
   docker run test-example
   ```

2. **Test with different platforms**
   ```bash
   # Test on different architectures if possible
   docker buildx build --platform linux/amd64,linux/arm64 .
   ```

3. **Validate documentation**
   - Check that all links work
   - Verify code examples run correctly
   - Ensure formatting is consistent

### Automated Testing
- All examples should pass automated builds
- Include health checks where applicable
- Add integration tests for complex examples

## 📤 Submitting Your Contribution

### Before Submitting
- [ ] Test your changes locally
- [ ] Update documentation
- [ ] Follow coding standards
- [ ] Add yourself to contributors list (if applicable)

### Pull Request Process
1. **Update your fork**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Push your changes**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create pull request**
   - Use descriptive title and description
   - Reference related issues
   - Include testing details
   - Add screenshots/demos if applicable

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New example
- [ ] Bug fix
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested locally
- [ ] Added/updated tests
- [ ] Documentation updated

## Related Issues
Fixes #(issue number)

## Screenshots/Demos
If applicable
```

## 🎖️ Recognition

### Contributors
All contributors will be recognized in:
- README.md contributors section
- Individual example credits
- Annual contributor highlights

### Maintainers
Active contributors may be invited to become maintainers with additional responsibilities:
- Code review privileges
- Issue triage
- Release management
- Community management

## 📞 Getting Help

### Communication Channels
- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: For private matters or security issues

### Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Best Practices](docs/best-practices.md)
- [Project Plan](docs/project-plan.md)

## 📜 Code of Conduct

### Our Pledge
We are committed to making participation in this project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Expected Behavior
- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

### Enforcement
Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team. All complaints will be reviewed and investigated promptly and fairly.

---

Thank you for contributing to the Dockerfile Examples project! Your contributions help make Docker more accessible to developers worldwide.
