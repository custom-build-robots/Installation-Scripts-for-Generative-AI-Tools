#!/bin/bash
# Author: Assistant
# Date: 2025-05-08
# Version: 0.1 alpha (not yet tested only written as an idea)
# Description: This script first displays the current n8n version installed via install_n8n.sh, prompts the user to confirm the upgrade,
#              then stops the n8n service, updates the globally installed n8n package to the latest stable version using npm,
#              clears the npm cache (optional), restarts the n8n service, and finally displays the newly installed n8n version.
#
# Usage: Save this script to a file (e.g., upgrade_n8n.sh), make it executable with 'chmod +x upgrade_n8n.sh',
#        and then run it with 'sudo ./upgrade_n8n.sh'.

set -e

# Get and display the current n8n version
current_version=$(n8n --version 2>/dev/null)
if [ -n "$current_version" ]; then
    echo "Current n8n version: $current_version"
else
    echo "Could not determine the current n8n version."
fi

# Prompt user for confirmation
read -p "Press Enter to proceed with the n8n upgrade..."

echo "Stopping the n8n service..."
sudo systemctl stop n8n

echo "Clearing npm cache (optional but recommended)..."
sudo npm cache clean -f

echo "Updating n8n to the latest stable version globally..."
sudo npm update -g n8n

echo "Starting the n8n service..."
sudo systemctl start n8n

echo "Checking the status of the n8n service..."
sudo systemctl status n8n

# Get and display the new n8n version
new_version=$(n8n --version 2>/dev/null)
if [ -n "$new_version" ]; then
    echo "Successfully upgraded n8n to version: $new_version"
else
    echo "Could not determine the new n8n version after the upgrade."
fi

echo "n8n upgrade process completed."
