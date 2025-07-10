# 🐳 Docker NAS Environment

[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docker.com)
[![Security](https://img.shields.io/badge/Security-First-green?logo=shield)](https://github.com/avctrust/docker)
[![NAS](https://img.shields.io/badge/NAS-Synology-orange?logo=synology)](https://synology.com)
[![SSH](https://img.shields.io/badge/SSH-Remote-red?logo=openssh)](https://openssh.com)

> **Secure Docker container environment for remote development on Synology NAS**

## 🎯 Overview

This repository contains the foundational SSH host environment for managing multiple Docker projects on a Synology NAS. It provides secure remote access, comprehensive analysis tools, and a controlled environment for development.

## 🏗️ Architecture

```
📁 Docker NAS Environment
├── 🏗️ avc_ssh_host/          # SSH container (this environment)
├── 🔧 scripts/               # Analysis and management tools
├── 📚 docs/                  # Documentation
├── 📊 analysis/              # Generated reports
└── 🚫 [41 projects ignored]  # Added incrementally
```

## 🔐 Security Features

- **🚨 Comprehensive `.gitignore`** - 41 Docker projects protected
- **🔑 SSH key management** - Secure remote access
- **📝 Environment isolation** - Each project containerized
- **🛡️ Secret management** - No credentials in version control
- **📋 Audit tools** - Regular security analysis

## 🚀 Quick Start

### Prerequisites
- Synology NAS with Docker installed
- SSH access to NAS
- Git configured

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/docker.git
cd docker
```

### 2. SSH Container Setup
```bash
cd avc_ssh_host
docker-compose up -d
```

### 3. Connect via SSH
```bash
ssh -p 2229 avctrust@your-nas-ip
```

## 🛠️ Available Tools

### Analysis Scripts
```bash
# Complete environment analysis
./scripts/docker-master-analysis.sh

# Port analysis
./scripts/docker-ports-analysis.sh

# Environment check
./scripts/docker-environment-analysis.sh

# List all projects
./scripts/list-docker-projects.sh
```

### VS Code Tasks
Available through VS Code Command Palette:
- 🔍 Complete Environment Analysis
- 🌐 Port Analysis
- 🏗️ Environment Analysis
- 📊 List Docker Projects
- 🚀 Connect to NAS Host

## 📊 Current Environment

- **Total Projects**: 41 Docker projects
- **With docker-compose**: 36 projects
- **With Dockerfile**: 31 projects
- **Python Projects**: 21 projects
- **Node.js Projects**: 1 project

## 🔄 Project Addition Strategy

Projects are added incrementally after security review:

1. **Security audit** of project
2. **Clean sensitive data**
3. **Create project-specific `.gitignore`**
4. **Update main `.gitignore`** to allow project
5. **Document project** in README
6. **Test and commit**

## 📁 Project Categories

### 🤖 AI & Automation
- avc_ai_terminal (Telegram bot)
- avc_gemini_bot (AI assistant)
- deepseek (AI interface)

### 🌐 Web Services
- avc_api (Main API)
- avc_remote_hub (Remote access)
- behavioural_dragon_pro (Main application)

### 🛠️ Development Tools
- avc_code_server (VS Code Server)
- avc_dev_container (Development environment)
- avc_sonarqube (Code analysis)

### 🗄️ Data & Storage
- avc_database (Database management)
- avc_db_mirror (Database replication)
- bind9 (DNS server)

### 🔧 Infrastructure
- avc_ssh_host (This container)
- avc_wireguard (VPN)
- nginx-rtmp (Streaming)

## 🔐 Security Guidelines

### Environment Variables
```bash
# ✅ GOOD: Use templates
cp .env.example .env
vim .env

# ❌ BAD: Never commit real .env files
git add .env  # This will be ignored
```

### SSH Keys
```bash
# ✅ GOOD: Store in ~/.ssh/
ssh-keygen -t ed25519 -f ~/.ssh/project_key

# ❌ BAD: Never commit private keys
# All *.key, *.pem files are ignored
```

### Secrets Management
```bash
# ✅ GOOD: Use Docker secrets
docker secret create db_password password.txt

# ❌ BAD: Hardcode in docker-compose
# password: "mysecretpassword"
```

## 📈 Monitoring

### System Resources
```bash
# Memory usage
free -h

# Disk usage
df -h

# Container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Log Analysis
```bash
# Container logs
docker logs container_name

# System logs
journalctl -u docker
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing-feature`)
5. **Open** Pull Request

### Commit Guidelines
```bash
# Use conventional commits
git commit -m "feat(ssh): add new analysis script"
git commit -m "fix(security): update gitignore patterns"
git commit -m "docs(readme): update installation guide"
```

## 📋 Changelog

### [1.0.0] - 2025-07-10
- Initial repository setup
- SSH host container configuration
- Comprehensive security configuration
- Analysis tools implementation
- Documentation structure

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🛡️ Security

If you discover security vulnerabilities, please send an email to security@yourdomain.com instead of opening an issue.

## 📞 Support

- 📧 Email: support@yourdomain.com
- 💬 Issues: [GitHub Issues](https://github.com/yourusername/docker/issues)
- 📖 Wiki: [Project Wiki](https://github.com/yourusername/docker/wiki)

## 🌟 Acknowledgments

- Synology for excellent NAS platform
- Docker for containerization technology
- VS Code team for remote development tools
- Open source community for inspiration

---

> **⚠️ Security Notice**: This repository uses security-first approach. All 41 Docker projects are ignored by default and added incrementally after security review.
