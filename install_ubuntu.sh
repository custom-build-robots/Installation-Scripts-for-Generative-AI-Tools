#!/bin/bash
# Autor: Ingmar Stapel
# Date:  2024-12-23
# Version: 0.8
# The script is used to setup a fresh Ubuntu installation.
# A NVIDIA GPU is used in the system for Deep Learning activities

# Hints:
# Make the script executable to run it locally with the following command
# chmod +x install_ubuntu.sh

# Run the script with the following command:
# ./install_ubuntu.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade packages
echo "Now we are updating the system..."
sleep 1
sudo apt-get update && sudo apt upgrade -y

# Install necessary tools
echo "Now we are installing a few tools we always need..."
sleep 3
sudo apt-get install -y mc openssh-server curl net-tools npm postgresql nodejs ffmpeg gnome-screenshot

# Install NVIDIA utils
echo "Now we are installing the NVIDIA Utils 550..."
sleep 3
sudo apt install -y nvidia-utils-550

# Add CUDA repository pin
echo "Now we are installing the NVIDIA CUDA driver..."
sleep 3
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Download and install the CUDA repository package
wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda-repo-ubuntu2404-12-6-local_12.6.0-560.28.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2404-12-6-local_12.6.0-560.28.03-1_amd64.deb

# Add CUDA keyring
sudo cp /var/cuda-repo-ubuntu2404-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/

# Update package lists after adding CUDA repository
sudo apt-get update

echo "Now we are installing the NVIDIA CUDA Toolkit..."
sleep 3
# Install CUDA toolkit and drivers
sudo apt-get install -y cuda-toolkit-12-6
sudo apt-get install -y cuda-drivers

# Notify user of successful installation
echo "Installation was completed successfully."

# Prompt user for confirmation before reboot
read -p "The system needs to reboot to apply changes. Press Enter to reboot or Ctrl+C to cancel..."

# Reboot the system to apply changes
sudo reboot
