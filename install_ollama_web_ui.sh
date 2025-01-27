#!/bin/bash
# Autor: Ingmar Stapel
# Date:  2024-12-23
# Version: 0.3
# The script is used to install Ollama Web UI.

# Hint:
# Ollama needs to be installed upfront.

# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade packages
echo "Now we are updating the system..."
sleep 3
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary tools
echo "Now we are installing some tools..."
sleep 3
sudo apt-get install -y curl gnupg lsb-release apt-transport-https

# Install Docker
echo "Now we are installing docker..."
sleep 3
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Check if Ollama is already running
echo "Now we are checking if ollama is installed..."
sleep 3
if pgrep -f "ollama" > /dev/null; then
    echo "Ollama is already installed and running. Skipping Ollama setup."
else
    echo "Ollama is not running. Ensure it is installed and operational before proceeding."
    exit 1
fi

# Run Open WebUI with CUDA and Ollama support using host networking
echo "Now we are loading the Ollama Web UI docker image..."
sleep 3
sudo docker run -d --network="host" \
  -v open-webui:/app/backend/data \
  -e OLLAMA_API_BASE_URL=http://localhost:11434/api \
  --restart always \
  --name open-webui \
  ghcr.io/ollama-webui/ollama-webui:latest

# Notify user of successful installation
echo "Installation was completed successfully. Access Open WebUI at http://<your-host-ip>:3000"
server_ip=$(hostname -I | awk '{print $1}')
echo "Access Open WebUI at http://$server_ip:8080"

# Prompt user for confirmation before reboot
read -p "The system needs to reboot to apply changes. Press Enter to reboot or Ctrl+C to cancel..."

# Reboot the system to apply changes
sudo reboot
