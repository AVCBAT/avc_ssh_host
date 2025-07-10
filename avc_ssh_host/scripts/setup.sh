#!/bin/bash

# Behavioural Dragon Pro - Setup Script
# Instala las dependencias necesarias para ejecutar el proyecto

echo "🐉 Behavioural Dragon Pro - Setup Script"
echo "=========================================="

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install Node.js and npm
echo "📦 Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
echo "✅ Verifying Node.js installation..."
node --version
npm --version

# Install project dependencies
echo "📦 Installing project dependencies..."
npm install

# Install Docker (optional)
echo "🐳 Installing Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

echo "✅ Setup completed!"
echo ""
echo "🚀 To start the application:"
echo "   Backend:  npm run server"
echo "   Frontend: npm run dev"
echo "   Full:     npm run dev:full"
echo ""
echo "🌐 Application will be available at:"
echo "   Frontend: http://localhost:5173"
echo "   Backend:  http://localhost:3000"
echo "   API Health: http://localhost:3000/api/health"
