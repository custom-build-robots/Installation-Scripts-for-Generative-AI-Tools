#!/bin/bash
# Autor: Ingmar Stapel
# Date:  2024-12-23
# Version: 0.4
# The script is used to setup n8n locally without docker.
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

# Install n8n globally via npm
echo "Installing n8n globally..."
sudo npm i -g n8n

# Create the n8n systemd service file
echo "Configuring n8n as a systemd service..."
SERVICE_FILE="/etc/systemd/system/n8n.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=n8n - Workflow Automation Tool
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/env NODE_ENV=production N8N_BASIC_AUTH_ACTIVE=true N8N_BASIC_AUTH_USER=admin N8N_BASIC_AUTH_PASSWORD=password123 N8N_SECURE_COOKIE=false n8n
Restart=always
User=$(whoami)
Environment="N8N_BASIC_AUTH_ACTIVE=true"
Environment="N8N_BASIC_AUTH_USER=admin"
Environment="N8N_BASIC_AUTH_PASSWORD=password123"
Environment="N8N_SECURE_COOKIE=false"

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable the n8n service
sudo systemctl daemon-reload
sudo systemctl enable n8n

# Start the n8n service
sudo systemctl start n8n

# Check service status
sudo systemctl status n8n

# Display access information
server_ip=$(hostname -I | awk '{print $1}')
echo "n8n has been installed and configured as a systemd service."
echo "Access n8n at: http://$server_ip:5678"
echo "Username: admin"
echo "Password: password123"

echo "If you are changing the n8n.service script you have to run the following commands:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart n8n"
echo "sudo systemctl status n8n"