#!/bin/bash
# Author: Ingmar Stapel
# Date: 2025-02-01
# Version: 0.5
# This script installs n8n locally without Docker and configures it as a systemd service.
# Exit immediately if any command exits with a non-zero status
set -e

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install Node.js if it is not already installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# Install n8n globally via npm
echo "Installing n8n globally..."
sudo npm i -g n8n

# Retrieve the server's IP address
server_ip=$(hostname -I | awk '{print $1}')
echo "Found IP address: $server_ip"

# Configure n8n as a systemd service
echo "Configuring n8n as a systemd service..."
SERVICE_FILE="/etc/systemd/system/n8n.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=n8n - Workflow Automation Tool
After=network.target

[Service]
Type=simple
# Set the dynamically detected IP address:
Environment="N8N_HOST=$server_ip"
# Other environment variables
Environment="NODE_ENV=production"
Environment="N8N_BASIC_AUTH_ACTIVE=true"
Environment="N8N_BASIC_AUTH_USER=admin"
Environment="N8N_BASIC_AUTH_PASSWORD=password123"
Environment="N8N_SECURE_COOKIE=false"
ExecStart=/usr/bin/env n8n
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd configuration and enable the n8n service
sudo systemctl daemon-reload
sudo systemctl enable n8n

# Start the n8n service
sudo systemctl start n8n

# Display the service status
sudo systemctl status n8n

# Display access information
echo "n8n has been installed and configured as a systemd service."
echo "Access n8n at: http://$server_ip:5678"
echo "Username: admin"
echo "Password: password123"
echo ""
echo "If you change the n8n.service file, run the following commands:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart n8n"
echo "sudo systemctl status n8n"
