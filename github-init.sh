#!/bin/bash

# ===============================================
# 🚀 GITHUB INITIALIZATION SCRIPT
# ===============================================
# Prepare Docker NAS environment for GitHub sync
# Generated: 2025-07-10

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🚀 Docker NAS GitHub Initialization${NC}"
echo "=================================================="
echo -e "Project: ${GREEN}Docker NAS Environment${NC}"
echo -e "Date: $(date)"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "$PROJECT_ROOT/.gitignore" ]] || [[ ! -f "$PROJECT_ROOT/README.md" ]]; then
    print_error "This script must be run from the project root or scripts directory"
    exit 1
fi

cd "$PROJECT_ROOT"

print_info "Working directory: $(pwd)"
echo ""

# Step 1: Verify required files
echo -e "${BLUE}📋 Step 1: Verifying required files${NC}"
echo "----------------------------------------"

required_files=(
    ".gitignore"
    ".gitattributes"
    "README.md"
    "LICENSE"
    "SECURITY.md"
    "CONTRIBUTING.md"
    "CHANGELOG.md"
    ".github/workflows/security.yml"
    ".github/workflows/docker.yml"
    ".markdownlint.json"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_status "$file exists"
    else
        print_error "$file is missing"
        missing_files+=("$file")
    fi
done

if [[ ${#missing_files[@]} -gt 0 ]]; then
    print_error "Missing required files. Please create them first."
    exit 1
fi

echo ""

# Step 2: Check Git configuration
echo -e "${BLUE}🔧 Step 2: Git configuration check${NC}"
echo "----------------------------------------"

if git status &>/dev/null; then
    print_warning "Git repository already initialized"
    
    # Check for existing remote
    if git remote get-url origin &>/dev/null; then
        current_remote=$(git remote get-url origin)
        print_info "Current remote: $current_remote"
    else
        print_warning "No remote origin configured"
    fi
else
    print_info "Initializing new Git repository..."
    git init
    print_status "Git repository initialized"
fi

# Check Git user configuration
if ! git config user.name &>/dev/null || ! git config user.email &>/dev/null; then
    print_warning "Git user not configured"
    echo ""
    echo "Please configure Git user:"
    echo "  git config user.name 'Your Name'"
    echo "  git config user.email 'your.email@example.com'"
    echo ""
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    git_user=$(git config user.name)
    git_email=$(git config user.email)
    print_status "Git user: $git_user <$git_email>"
fi

echo ""

# Step 3: Security validation
echo -e "${BLUE}🔐 Step 3: Security validation${NC}"
echo "----------------------------------------"

# Check for sensitive files
print_info "Checking for sensitive files..."

sensitive_patterns=(
    "*.env"
    "*.key"
    "*.pem"
    "*.p12"
    "*.pfx"
    "id_rsa*"
    "*.crt"
    "*.cert"
)

found_sensitive=false
for pattern in "${sensitive_patterns[@]}"; do
    if find . -name "$pattern" -type f | grep -q .; then
        print_warning "Found potentially sensitive files matching: $pattern"
        find . -name "$pattern" -type f | head -5
        found_sensitive=true
    fi
done

if $found_sensitive; then
    print_warning "Sensitive files found. These should be in .gitignore"
    echo ""
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_status "No sensitive files found in workspace"
fi

# Verify .gitignore coverage
print_info "Verifying .gitignore coverage..."

if grep -q "# IGNORE ALL DOCKER PROJECTS BY DEFAULT" .gitignore; then
    print_status ".gitignore has project exclusion strategy"
else
    print_warning ".gitignore missing project exclusion strategy"
fi

echo ""

# Step 4: Project structure validation
echo -e "${BLUE}📁 Step 4: Project structure validation${NC}"
echo "----------------------------------------"

# Count projects
total_projects=$(find . -maxdepth 1 -type d -name "avc_*" -o -name "behavioural_*" -o -name "bind9" -o -name "deepseek" | wc -l)
print_info "Total Docker projects found: $total_projects"

# Check SSH host
if [[ -d "avc_ssh_host" ]] && [[ -f "avc_ssh_host/docker-compose.yml" ]]; then
    print_status "SSH host container configured"
else
    print_error "SSH host container missing or misconfigured"
fi

# Check scripts
if [[ -d "avc_ssh_host/scripts" ]]; then
    script_count=$(find avc_ssh_host/scripts -name "*.sh" | wc -l)
    print_status "Analysis scripts found: $script_count"
else
    print_warning "Scripts directory not found"
fi

echo ""

# Step 5: Create initial commit
echo -e "${BLUE}📝 Step 5: Prepare initial commit${NC}"
echo "----------------------------------------"

# Add files to Git
print_info "Adding files to Git..."

# Add base configuration files
git add .gitignore .gitattributes README.md LICENSE SECURITY.md CONTRIBUTING.md CHANGELOG.md .markdownlint.json

# Add GitHub workflows
if [[ -d ".github" ]]; then
    git add .github/
    print_status "GitHub workflows added"
fi

# Add SSH host environment only
if [[ -d "avc_ssh_host" ]]; then
    git add avc_ssh_host/
    print_status "SSH host environment added"
fi

# Check what will be committed
files_to_commit=$(git diff --cached --name-only | wc -l)
print_info "Files staged for commit: $files_to_commit"

if [[ $files_to_commit -eq 0 ]]; then
    print_warning "No files staged for commit"
else
    print_status "Ready for initial commit"
fi

echo ""

# Step 6: Final instructions
echo -e "${BLUE}🎯 Step 6: Next steps${NC}"
echo "----------------------------------------"

print_info "Repository is ready for GitHub!"
echo ""
echo "Next steps:"
echo ""
echo "1. 🔗 Create GitHub repository:"
echo "   - Go to: https://github.com/new"
echo "   - Repository name: docker"
echo "   - Description: Docker NAS Environment for Synology"
echo "   - Set to Public or Private as needed"
echo "   - Do NOT initialize with README (we have our own)"
echo ""

echo "2. 📡 Add remote and push:"
echo "   git remote add origin https://github.com/yourusername/docker.git"
echo "   git branch -M main"
echo "   git commit -m \"feat: initial Docker NAS environment setup"
echo ""
echo "   🏗️ SSH host container with secure remote access"
echo "   🔐 Comprehensive security configuration"
echo "   🛠️ Analysis tools and monitoring scripts"
echo "   📚 Complete documentation suite"
echo "   🚫 All 41 projects ignored by default for security"
echo "   \""
echo "   git push -u origin main"
echo ""

echo "3. 🔐 Configure GitHub settings:"
echo "   - Enable branch protection for main"
echo "   - Require PR reviews"
echo "   - Enable security alerts"
echo "   - Set up dependabot"
echo ""

echo "4. 🚀 Add projects incrementally:"
echo "   - Review each project for security"
echo "   - Clean sensitive data"
echo "   - Update .gitignore to allow specific project"
echo "   - Test and commit"
echo ""

print_status "Initialization complete! 🎉"

# Optional: Show git status
echo ""
echo -e "${BLUE}📊 Current Git status:${NC}"
echo "----------------------------------------"
git status --short

echo ""
echo "Happy coding! 🐳"
