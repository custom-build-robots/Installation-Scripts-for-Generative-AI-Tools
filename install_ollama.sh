#!/bin/bash
# Autor: Ingmar Stapel
# Date:  2024-12-23
# Version: 0.8
# The script is used to install Ollama on your system.

# Make it executable
# chmod +x setup_server.sh

# Run the script:
# ./ubuntu_install.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade packages
echo "Now we are updating the system..."
sleep 3
sudo apt-get update && sudo apt upgrade -y

echo "We are now installing Ollama on your system"
sleep 3
curl -fsSL https://ollama.com/install.sh | sh

echo "Your are now running Ollama version:"
ollama --version
sleep 3

echo "We are now checking if a LLM is already available..."
ollama list
sleep 3

echo "We are now downloading mistral or updating it...."
ollama pull mistral

echo "We are checking again if an LLM is available..."
ollama list
sleep 3

# Notify user of successful installation
echo "Installation was completed successfully."
