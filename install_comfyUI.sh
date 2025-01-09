#!/bin/bash
# Author: Ingmar Stapel
# Date:  2025-01-09
# Version: 0.2
# The script is used to install ComfyUI in a virtual environment with Python 3.11.

# Exit immediately if a command exits with a non-zero status
set -e

# Enable debugging (optional, remove or comment out in production)
# set -x

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Python 3.11
if ! command_exists python3.11; then
    echo "Python 3.11 is not installed. Installing Python 3.11..."
    sudo apt update
    sudo apt install -y python3.11 python3.11-venv python3.11-dev git
fi

# Update and upgrade system packages
echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

REPO_DIR="$HOME/ComfyUI"

# Clone the ComfyUI repository if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning ComfyUI repository..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$REPO_DIR"
else
    echo "ComfyUI repository already exists. Pulling latest changes..."
    cd "$REPO_DIR"
    git pull
fi

cd "$REPO_DIR"

# Create a Python virtual environment if it doesn't exist
if [ ! -d "venv_comfyUI" ]; then
    echo "Creating a Python virtual environment..."
    python3.11 -m venv venv_comfyUI
else
    echo "Virtual environment already exists."
fi

# Activate the virtual environment
echo "Activating the virtual environment..."
source venv_comfyUI/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install required Python packages
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Prepare installation of ComfyUI Manager
CUSTOM_NODES_DIR="$REPO_DIR/custom_nodes"
if [ ! -d "$CUSTOM_NODES_DIR/ComfyUI-Manager" ]; then
    echo "Installing ComfyUI-Manager..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager "$CUSTOM_NODES_DIR/ComfyUI-Manager"
else
    echo "ComfyUI-Manager already installed."
fi

# Deactivate the virtual environment
echo "Deactivating the virtual environment..."
deactivate

# Create a systemd service file for ComfyUI
echo "Configuring ComfyUI systemd service..."
SERVICE_FILE="/etc/systemd/system/comfyUI.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Type=simple
ExecStart=$REPO_DIR/venv_comfyUI/bin/python $REPO_DIR/main.py --listen
WorkingDirectory=$REPO_DIR
User=$(whoami)
Restart=always
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOL

# Set correct permissions for the service file
sudo chmod 644 $SERVICE_FILE
sudo chown root:root $SERVICE_FILE

# Reload systemd and enable the ComfyUI service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling ComfyUI service to start on boot..."
sudo systemctl enable comfyUI

# Start the ComfyUI service
echo "Starting ComfyUI service..."
sudo systemctl start comfyUI

# Check service status
echo "Checking ComfyUI service status..."
sudo systemctl status comfyUI --no-pager

# Display access information
server_ip=$(hostname -I | awk '{print $1}')
echo "ComfyUI has been installed and configured as a systemd service."
echo "Access ComfyUI at: http://$server_ip"

echo "If you modify the comfyUI.service file, run the following commands:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart comfyUI"
echo "sudo systemctl status comfyUI"
