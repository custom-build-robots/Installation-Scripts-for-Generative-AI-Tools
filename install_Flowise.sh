#!/bin/bash
# Autor: Ingmar Stapel
# Date:  2025-01-31
# Version: 0.6
# The script is used to setup Flowise locally without docker.
# It configures Flowise to log under /usr/local/lib/node_modules/flowise/logs

# Exit immediately if a command exits with a non-zero status
set -e

# 1. Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# 2. Install Node.js (if not already installed)
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# 3. Install Flowise globally via npm
echo "Installing Flowise globally..."
sudo npm i -g flowise

# 4. Create (and fix permissions for) the Flowise log directory
# If we set the logs directory in the home folder flowise will not start due to permission problems.
# That may cause errors in a new flowise version but currently it is working.
LOG_DIR="/usr/local/lib/node_modules/flowise/logs"
echo "Ensuring Flowise log directory at $LOG_DIR..."
sudo mkdir -p "$LOG_DIR"

# Set the owner to the current user so Flowise can write logs there
sudo chown -R $(whoami):$(whoami) "$LOG_DIR"

# 5. Create the Flowise systemd service file
echo "Configuring Flowise as a systemd service..."
SERVICE_FILE="/etc/systemd/system/flowise.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Flowise - AI Workflow Automation Tool
After=network.target

[Service]
Type=simple
# We run as the current user, which can write to /usr/local/lib/node_modules/flowise/logs
User=$(whoami)
Group=$(whoami)
ExecStart=/usr/bin/flowise start --PORT=3001
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# 6. Reload systemd and enable the Flowise service
sudo systemctl daemon-reload
sudo systemctl enable flowise

# 7. Start the Flowise service
sudo systemctl start flowise

# 8. Check service status
sudo systemctl status flowise --no-pager || true

# 9. Display access information
server_ip=$(hostname -I | awk '{print $1}')
echo "-----------------------------------------------------------"
echo "Flowise has been installed and configured as a systemd service."
echo "You can access Flowise at: http://$server_ip:3001"
echo
echo "If you modify the flowise.service file, run these commands to apply changes:"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl restart flowise"
echo "  sudo systemctl status flowise"
echo "-----------------------------------------------------------"
