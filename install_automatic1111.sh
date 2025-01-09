#!/bin/bash
# Author: Ingmar Stapel
# Date:  2024-12-31
# Version: 0.1
# The script is used to install AUTOMATIC1111's Stable Diffusion WebUI in a virtual environment with Python 3.11.
# The configuration allow access to Automatic1111 over your home network from any connected device on port 7864.

# Exit immediately if a command exits with a non-zero status
set -e

# Add deadsnakes PPA for older Python versions
echo "Adding deadsnakes PPA..."
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

# Update and upgrade system packages
echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "Installing required dependencies..."
sudo apt install -y python3.11 python3.11-venv python3.11-dev git wget curl ffmpeg libsm6 libxext6 libgl1

# Verify Python 3.11 installation
if ! command -v python3.11 &> /dev/null; then
    echo "Python 3.11 is not installed. Exiting..."
    exit 1
fi

echo "Python 3.11 is installed."

# Clone the Stable Diffusion WebUI repository
echo "Cloning the Stable Diffusion WebUI repository..."
REPO_DIR="$HOME/stable-diffusion-webui"
if [ -d "$REPO_DIR" ]; then
    echo "Repository already exists. Pulling latest changes..."
    cd "$REPO_DIR"
    git pull
else
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Create a Python virtual environment
echo "Creating a Python virtual environment..."
python3.11 -m venv venv_automatic1111

# Activate the virtual environment
echo "Activating the virtual environment..."
source venv_automatic1111/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install required Python packages
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Deactivate the virtual environment
echo "Deactivating the virtual environment..."
deactivate

# Create a systemd service file for Stable Diffusion WebUI
echo "Configuring Stable Diffusion WebUI as a systemd service..."
SERVICE_FILE="/etc/systemd/system/stable-diffusion-webui.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Stable Diffusion WebUI
After=network.target

[Service]
Type=simple
# ExecStart=/home/ingmar/stable-diffusion-webui/venv_automatic1111/bin/python /home/ingmar/stable-diffusion-webui/launch.py --share --listen --port 7864 --ckpt-dir /mnt/temp_03/Stable_Diffusion_models/
# ExecStart=$REPO_DIR/venv_automatic1111/bin/python $REPO_DIR/launch.py --share --port 7864
ExecStart=$REPO_DIR/venv_automatic1111/bin/python $REPO_DIR/launch.py --share --listen --port 7864
WorkingDirectory=$REPO_DIR
User=$(whoami)
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable the Stable Diffusion WebUI service
sudo systemctl daemon-reload
sudo systemctl enable stable-diffusion-webui

# Start the Stable Diffusion WebUI service
sudo systemctl start stable-diffusion-webui

# Check service status
sudo systemctl status stable-diffusion-webui

# Display access information
server_ip=$(hostname -I | awk '{print $1}')
echo "Stable Diffusion WebUI has been installed and configured as a systemd service."
echo "Access the WebUI at: http://$server_ip:7860"

echo "If you modify the stable-diffusion-webui.service file, run the following commands:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart stable-diffusion-webui"
echo "sudo systemctl status stable-diffusion-webui"
