#!/bin/bash
# Autor: Ingmar Stapel
# Date:  2024-12-23
# Version: 0.4
# The script is used to setup Flowise locally without docker.
# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install Node.js (if not already installed)
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# Install Flowise globally via npm
echo "Installing Flowise globally..."
sudo npm i -g flowise

# Create the Flowise log directory
LOG_DIR="/home/$(whoami)/flowise/logs"
echo "Creating Flowise log directory at $LOG_DIR..."
mkdir -p "$LOG_DIR"
sudo chown -R $(whoami):$(whoami) "$LOG_DIR"

# Create the Flowise systemd service file
echo "Configuring Flowise as a systemd service..."
SERVICE_FILE="/etc/systemd/system/flowise.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Flowise - AI Workflow Automation Tool
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/env NODE_ENV=production FLOWISE_HOST=0.0.0.0 FLOWISE_LOG_DIR=$LOG_DIR flowise start --PORT=3001
Restart=always
User=$(whoami)
Environment="FLOWISE_HOST=0.0.0.0"
Environment="FLOWISE_PORT=3001"
Environment="FLOWISE_LOG_DIR=$LOG_DIR"

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable the Flowise service
sudo systemctl daemon-reload
sudo systemctl enable flowise

# Start the Flowise service
sudo systemctl start flowise

# Check service status
sudo systemctl status flowise

# Display access information
server_ip=$(hostname -I | awk '{print $1}')
echo "Flowise has been installed and configured as a systemd service."
echo "Access Flowise at: http://$server_ip:3001"
echo "If you are changing the flowise.service script you have to run the following commands:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart flowise"
echo "sudo systemctl status flowise"