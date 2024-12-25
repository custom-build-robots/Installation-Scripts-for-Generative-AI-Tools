#!/bin/bash
# Author: Your Name
# Date: 2024-12-23
# Version: 1.2
# Description: This script installs OpenAI's Whisper project for offline usage on an Ubuntu machine.


# Generate a Hugging Face Access Token:

# Log in to your Hugging Face account.
# Go to your Access Tokens page.
# Generate a new token and copy it.
# Update the Script to Use the Token: Add your Hugging Face token to the wget command for authentication.
# Define the Hugging Face token (replace YOUR_HUGGINGFACE_TOKEN with your token)
HUGGINGFACE_TOKEN="YOUR_HUGGINGFACE_TOKEN"

# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install Python3, pip, and venv (if not already installed)
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Installing Python3..."
    sudo apt install -y python3
else
    echo "Python3 is already installed."
fi

if ! command -v pip3 &> /dev/null; then
    echo "pip3 not found. Installing pip3..."
    sudo apt install -y python3-pip
else
    echo "pip3 is already installed."
fi

if ! dpkg -s python3-venv &> /dev/null; then
    echo "Python3 venv not found. Installing python3-venv..."
    sudo apt install -y python3-venv
else
    echo "Python3 venv is already installed."
fi

# Create a directory for Whisper
WHISPER_DIR="$HOME/whisper_offline"
if [ -d "$WHISPER_DIR" ]; then
    echo "Whisper directory already exists at $WHISPER_DIR"
else
    echo "Creating directory for Whisper at $WHISPER_DIR..."
    mkdir -p "$WHISPER_DIR"
fi

# Clone the Whisper repository
echo "Cloning the Whisper repository..."
git clone https://github.com/openai/whisper.git "$WHISPER_DIR"

# Change to the Whisper directory
cd "$WHISPER_DIR"

# Create and activate a virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv venv_whisper || { echo "Failed to create virtual environment. Ensure python3-venv is installed."; exit 1; }
source venv_whisper/bin/activate

# Install Whisper dependencies
echo "Installing Whisper dependencies..."
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# Download the Whisper model files (base model by default)
MODELS_DIR="$WHISPER_DIR/models"
echo "Creating models directory at $MODELS_DIR..."
mkdir -p "$MODELS_DIR"


# NOTE: For the latest model URLs, refer to the official Whisper repository:
# https://github.com/openai/whisper/blob/main/whisper/__init__.py

# Define the model URL and download it with authentication
MODEL_URL="https://huggingface.co/openai/whisper-base/resolve/main/model.bin"
echo "Downloading the Whisper base model with authentication..."
wget --header="Authorization: Bearer $HUGGINGFACE_TOKEN" -O "$MODELS_DIR/model.bin" "$MODEL_URL"


# Test Whisper installation
echo "Testing Whisper installation..."
python -c "import whisper; model = whisper.load_model('base'); print('Whisper is installed and ready to use.')"

# Deactivate the virtual environment
deactivate

# Display completion message
echo "Whisper has been installed successfully for offline usage."
