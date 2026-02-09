#!/bin/bash
set -e

echo "🚀 Installing Tero Infrastructure Dependencies for Ubuntu Server"
echo "=================================================================="

# Update system packages
echo ""
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential tools
echo ""
echo "🔧 Installing essential tools..."
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker
echo ""
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. You may need to log out and back in for group changes to take effect."
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose (standalone - for compatibility)
echo ""
echo "🐳 Installing Docker Compose standalone..."
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed: $DOCKER_COMPOSE_VERSION"
else
    echo "✅ Docker Compose already installed"
fi

# Install Rust
echo ""
echo "🦀 Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    echo "✅ Rust installed: $(rustc --version)"
else
    echo "✅ Rust already installed: $(rustc --version)"
fi

# Install Just
echo ""
echo "⚡ Installing Just..."
if ! command -v just &> /dev/null; then
    # Use cargo to install just
    source "$HOME/.cargo/env"
    cargo install just
    echo "✅ Just installed: $(just --version)"
else
    echo "✅ Just already installed: $(just --version)"
fi

# Install .NET SDK
echo ""
echo "🔷 Installing .NET SDK..."
if ! command -v dotnet &> /dev/null; then
    # Add Microsoft package repository
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb

    # Install .NET SDK
    sudo apt update
    sudo apt install -y dotnet-sdk-8.0
    echo "✅ .NET SDK installed: $(dotnet --version)"
else
    echo "✅ .NET SDK already installed: $(dotnet --version)"
fi

# Install additional useful tools
echo ""
echo "🛠️  Installing additional tools..."
sudo apt install -y \
    htop \
    vim \
    tmux \
    jq \
    unzip

echo ""
echo "=================================================================="
echo "✨ All dependencies installed successfully!"
echo "=================================================================="
echo ""
echo "📝 Next steps:"
echo "  1. Log out and back in (or run: newgrp docker) for Docker permissions"
echo "  2. Verify installations:"
echo "     - docker --version"
echo "     - docker-compose --version"
echo "     - rustc --version"
echo "     - just --version"
echo "     - dotnet --version"
echo "  3. Clone your service repositories:"
echo "     - git clone <tero.platform-repo>"
echo "     - git clone <tero.session-repo>"
echo "  4. Configure and run: ./run.sh"
echo ""
