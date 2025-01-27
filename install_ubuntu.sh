#!/bin/bash
# Autor: Ingmar Stapel
# Date:  2025-01-27
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
sudo apt-get install -y mc openssh-server curl net-tools npm nodejs ffmpeg yt-dlp gnome-screenshot obs-studio imagemagick

# Install NVIDIA utils
echo "Now we are installing the NVIDIA Utils 550..."
sleep 3
sudo apt install -y nvidia-utils-550

# Add CUDA repository pin
echo "Now we are installing the NVIDIA CUDA driver..."
sleep 3
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update -y
sudo apt-get -y install cuda-toolkit-12-6


sudo apt-get install -y cuda-drivers

# Notify user of successful installation
echo "CUDA Installation was completed successfully."
sleep 3

# installing chrome
echo "Now installing chrome as browser"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Prompt user for confirmation before reboot
read -p "The system needs to reboot to apply changes. Press Enter to reboot or Ctrl+C to cancel..."

# Reboot the system to apply changes
echo "Now rebooting the system"
sudo reboot
