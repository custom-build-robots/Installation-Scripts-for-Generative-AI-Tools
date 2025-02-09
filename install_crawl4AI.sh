#!/bin/bash
# Author: Your Name
# Date: 2025-02-09
# Version: 0.9
# Description:
#   This script installs Crawl4AI by cloning its repository, overriding its compose
#   file with a patched version for local builds, and then building and running the
#   Docker container (AMD64) via Docker Compose.
#
#   Once completed, Crawl4AI will be accessible on port 11235.
#
# Notes:
#   - Ensure any required environment variables (e.g., API tokens) are set.
#   - The script uses the "local-amd64" profile defined in our patched compose file.
#   - The repository URL is assumed to be https://github.com/unclecode/crawl4ai.git

# Exit immediately if any command fails.
set -e

# Check for root privileges.
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (or via sudo)."
    exit 1
fi

echo "Updating system packages..."
apt-get update && apt-get upgrade -y

echo "Installing necessary tools (curl, git, etc.)..."
apt-get install -y curl git apt-transport-https ca-certificates lsb-release

echo "Installing Docker..."
# Remove old Docker packages if present (ignore errors)
apt-get remove -y docker docker-engine docker.io containerd runc || true
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Check if Docker Compose is installed; if not, install it.
if ! command -v docker-compose &>/dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Define installation directory and repository URL.
INSTALL_DIR="/opt/crawl4ai"
REPO_URL="https://github.com/unclecode/crawl4ai.git"

# Clone the repository if not already present, or update it if it exists.
if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "Cloning Crawl4AI repository into $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
else
    echo "Crawl4AI repository already exists. Updating..."
    cd "$INSTALL_DIR"
    git pull
fi

# Change to the repository root.
cd "$INSTALL_DIR"

# Overwrite the repository's docker-compose.yml with our patched version.
# This file uses an extension field (x-base-config) to define shared configuration,
# then merges that into each service.
cat > docker-compose.yml << 'EOF'
version: "3.9"

x-base-config: &base-config
  ports:
    - "11235:11235"
    - "8000:8000"
    - "9222:9222"
    - "8080:8080"
  environment:
    - CRAWL4AI_API_TOKEN=${CRAWL4AI_API_TOKEN:-}
    - OPENAI_API_KEY=${OPENAI_API_KEY:-}
    - CLAUDE_API_KEY=${CLAUDE_API_KEY:-}
  volumes:
    - /dev/shm:/dev/shm
  deploy:
    resources:
      limits:
        memory: 4G
      reservations:
        memory: 1G
  restart: unless-stopped
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:11235/health"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 40s

services:
  crawl4ai-amd64:
    <<: *base-config
    build:
      context: .
      dockerfile: Dockerfile
      args:
        PYTHON_VERSION: "3.10"
        INSTALL_TYPE: ${INSTALL_TYPE:-basic}
        ENABLE_GPU: "false"
      platforms:
        - linux/amd64
    profiles: ["local-amd64"]

  crawl4ai-arm64:
    <<: *base-config
    build:
      context: .
      dockerfile: Dockerfile
      args:
        PYTHON_VERSION: "3.10"
        INSTALL_TYPE: ${INSTALL_TYPE:-basic}
        ENABLE_GPU: "false"
      platforms:
        - linux/arm64
    profiles: ["local-arm64"]

  crawl4ai-hub-amd64:
    <<: *base-config
    image: unclecode/crawl4ai:${VERSION:-basic}-amd64
    profiles: ["hub-amd64"]

  crawl4ai-hub-arm64:
    <<: *base-config
    image: unclecode/crawl4ai:${VERSION:-basic}-arm64
    profiles: ["hub-arm64"]
EOF

echo "Patched docker-compose.yml written to $INSTALL_DIR."

# (Optional) Export environment variables for API tokens, if needed.
# export CRAWL4AI_API_TOKEN="your_api_token_here"
# export OPENAI_API_KEY="your_openai_api_key_here"
# export CLAUDE_API_KEY="your_claude_api_key_here"
# export INSTALL_TYPE="basic"  # Or another install type if required.

echo "Building and starting Crawl4AI container (AMD64) using Docker Compose..."
# Use the "local-amd64" profile for the local build.
docker-compose --profile local-amd64 up -d

echo "Verifying the container status..."
docker ps --filter "name=crawl4ai-amd64" || true

# Get the server's IP address (first IP listed).
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Installation complete. Access Crawl4AI at: http://$SERVER_IP:11235"
