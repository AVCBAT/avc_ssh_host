# Contributing Guide

## 🤝 Welcome Contributors!

Thank you for your interest in contributing to the Docker NAS Environment project! This guide will help you get started.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Contribution Types](#contribution-types)
- [Pull Request Process](#pull-request-process)
- [Security Guidelines](#security-guidelines)
- [Style Guidelines](#style-guidelines)

## 🤝 Code of Conduct

This project adheres to a code of conduct that ensures a welcoming environment for all contributors. By participating, you agree to uphold this code.

### Our Standards

- ✅ Be respectful and inclusive
- ✅ Use welcoming and inclusive language
- ✅ Focus on constructive feedback
- ✅ Show empathy towards other contributors
- ❌ No harassment, trolling, or inappropriate content
- ❌ No personal attacks or political discussions

## 🚀 Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Git configured with your credentials
- SSH access to test environment
- Basic knowledge of containerization

### Development Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/yourusername/docker.git
   cd docker
   ```

2. **Set up remote tracking**
   ```bash
   git remote add upstream https://github.com/avctrust/docker.git
   git fetch upstream
   ```

3. **Create development branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Test SSH host environment**
   ```bash
   cd avc_ssh_host
   docker-compose up -d
   docker-compose exec avc_ssh_host /bin/bash
   ```

## 🔄 Development Workflow

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Individual feature branches
- `hotfix/*` - Emergency fixes
- `release/*` - Release preparation

### Workflow Steps

1. **Sync with upstream**
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make changes**
   ```bash
   # Edit files
   # Test changes
   # Commit incrementally
   ```

4. **Test thoroughly**
   ```bash
   # Run security checks
   ./scripts/docker-master-analysis.sh
   
   # Test Docker builds
   cd avc_ssh_host
   docker-compose build
   docker-compose up -d
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/amazing-feature
   # Create Pull Request on GitHub
   ```

## 🎯 Contribution Types

### 🐛 Bug Reports

**Before submitting:**
- Search existing issues
- Test with latest version
- Reproduce in clean environment

**Include in report:**
- Environment details (OS, Docker version)
- Steps to reproduce
- Expected vs actual behavior
- Logs and error messages
- Screenshots if applicable

### ✨ Feature Requests

**Before submitting:**
- Check if feature already exists
- Search existing feature requests
- Consider if it fits project scope

**Include in request:**
- Clear description of feature
- Use cases and examples
- Potential implementation approach
- Impact on existing functionality

### 📚 Documentation

**Documentation improvements:**
- Fix typos and grammar
- Add missing information
- Improve clarity and examples
- Update outdated content
- Add translations

### 🔧 Code Contributions

**Code improvements:**
- Bug fixes
- New features
- Performance optimizations
- Security enhancements
- Test coverage improvements

## 🔀 Pull Request Process

### PR Requirements

1. **✅ Checklist before submitting:**
   - [ ] Code follows style guidelines
   - [ ] Tests pass locally
   - [ ] Documentation updated
   - [ ] Security review completed
   - [ ] No sensitive data committed
   - [ ] Docker images build successfully

2. **📝 PR Description:**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Security improvement
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Integration tests pass
   - [ ] Manual testing completed
   
   ## Security Review
   - [ ] No secrets committed
   - [ ] Security implications considered
   - [ ] Permissions reviewed
   ```

### Review Process

1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Security review** for sensitive changes
4. **Testing** in staging environment
5. **Approval** by project maintainers

### Merge Requirements

- ✅ All checks passing
- ✅ At least one approval
- ✅ Up-to-date with target branch
- ✅ Conflicts resolved
- ✅ Security review completed

## 🔐 Security Guidelines

### 🚨 Critical Security Rules

❌ **NEVER commit:**
- Real `.env` files
- Private SSH keys
- Database credentials
- API tokens/secrets
- SSL certificates

✅ **ALWAYS:**
- Use `.env.example` templates
- Run security scans before PR
- Review code for sensitive data
- Test access controls
- Document security changes

### Security Review Process

1. **Automated scanning** via GitHub Actions
2. **Manual review** for sensitive areas
3. **Permission verification** for new features
4. **Vulnerability assessment** for dependencies
5. **Penetration testing** for major changes

## 📐 Style Guidelines

### Git Commit Messages

```bash
# Format: type(scope): description
feat(ssh): add new authentication method
fix(security): resolve vulnerability in auth
docs(readme): update installation guide
style(docker): format docker-compose files
refactor(scripts): optimize analysis tools
test(ci): add integration tests
chore(deps): update dependencies
```

### Code Style

**Shell Scripts:**
```bash
#!/bin/bash
# Use strict mode
set -euo pipefail

# Function naming: snake_case
function analyze_environment() {
    local project_dir="$1"
    # Implementation
}

# Constants: UPPER_CASE
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

**Docker:**
```dockerfile
# Use specific versions
FROM alpine:3.18

# Group related commands
RUN apk update && \
    apk add --no-cache \
        openssh-server \
        bash \
    && rm -rf /var/cache/apk/*

# Use COPY instead of ADD
COPY scripts/ /usr/local/bin/

# Run as non-root
USER 1000:1000
```

**Documentation:**
- Use British English spelling
- Keep lines under 100 characters
- Use emoji for visual clarity
- Include code examples
- Link to relevant resources

### File Organization

```
project/
├── README.md           # Project overview
├── CONTRIBUTING.md     # This file
├── SECURITY.md         # Security policy
├── LICENSE            # License terms
├── .github/           # GitHub templates
│   ├── workflows/     # CI/CD workflows
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/             # Additional documentation
├── scripts/          # Utility scripts
└── avc_ssh_host/     # Main SSH container
```

## 🧪 Testing Guidelines

### Test Categories

1. **Unit Tests**
   - Individual function testing
   - Mock external dependencies
   - Fast execution

2. **Integration Tests**
   - Multi-component testing
   - Docker container testing
   - Network connectivity

3. **Security Tests**
   - Vulnerability scanning
   - Permission verification
   - Secret detection

4. **Performance Tests**
   - Resource usage
   - Response times
   - Scalability

### Running Tests

```bash
# Run all tests
./scripts/run-tests.sh

# Run specific test category
./scripts/run-tests.sh --security
./scripts/run-tests.sh --integration

# Run with coverage
./scripts/run-tests.sh --coverage
```

## 📞 Getting Help

### Community Support

- 💬 **GitHub Discussions** - General questions and ideas
- 🐛 **GitHub Issues** - Bug reports and feature requests
- 📧 **Email** - security@yourdomain.com (security issues)

### Maintainer Contact

- **Lead Maintainer**: [@avctrust](https://github.com/avctrust)
- **Security Team**: security@yourdomain.com
- **Response Time**: 24-48 hours for issues

## 🎉 Recognition

Contributors will be recognized in:

- 📋 **CONTRIBUTORS.md** file
- 🏆 **Release notes** for significant contributions
- 🌟 **GitHub achievements** and badges
- 📢 **Project blog** for major features

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Git Workflow Guide](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Security Guidelines](./SECURITY.md)
- [Project Documentation](./docs/)

---

> **Thank you for contributing!** Every contribution, no matter how small, makes this project better for everyone. 🙏
