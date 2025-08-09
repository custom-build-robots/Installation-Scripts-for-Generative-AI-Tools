#!/bin/bash

# This script automates the full installation of the AI-Toolkit on Ubuntu,
# including the Python backend engine and the Node.js management UI.
# It correctly sets up a single systemd service to run the UI, which in
# turn manages the backend Python jobs.

# This script was optimized for my server setup which well had it's own problems / history.

# --- Configuration ---
# The directory where the AI-Toolkit will be installed.
INSTALL_DIR="$HOME/ai-toolkit"
# The Git repository URL for the AI-Toolkit.
GIT_REPO="https://github.com/ostris/ai-toolkit.git"
# The name of the systemd service file for the UI.
UI_SERVICE_NAME="ai-toolkit-ui.service"
# The port for the frontend UI, as per the official documentation.
UI_PORT=8675
# OPTIONAL: Set a password here to secure your UI.
# Leave it blank to run without a password.
AUTH_TOKEN=""

# --- Script Execution ---

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Correct AI-Toolkit UI Installation ---"

# 1. System Dependencies
echo "--> Step 1: Installing system dependencies (git, python, nodejs, build tools)..."
sudo apt-get update
# Install curl to fetch the Node.js setup script
sudo apt-get install -y git python3-venv build-essential cmake pkg-config curl

# 2. Node.js Installation (using NodeSource for a modern version)
echo "--> Step 2: Setting up Node.js v20..."
# Check if a compatible Node.js version is installed.
if ! command -v node > /dev/null || ! node -v | grep -qE "v(18\.(18|[2-9][0-9])|19|[2-9][0-9])\."; then
    echo "Node.js not found or version is too old. Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Sufficient Node.js version found. Skipping installation."
fi
echo "Node.js setup complete."

# 3. Clone the AI-Toolkit repository
echo "--> Step 3: Cloning AI-Toolkit repository..."
if [ -d "$INSTALL_DIR" ]; then
    echo "Installation directory $INSTALL_DIR already exists. Deleting for a clean install."
    rm -rf "$INSTALL_DIR"
fi
git clone "$GIT_REPO" "$INSTALL_DIR"
cd "$INSTALL_DIR"
echo "Repository cloned successfully."

# 4. Python Backend Engine Setup (Dependencies only)
echo "--> Step 4: Setting up Python backend engine dependencies..."
echo "Creating Python virtual environment..."
python3 -m venv venv

# Get the full path to the venv's pip executable.
PIP_PATH="$INSTALL_DIR/venv/bin/pip3"

echo "Installing Python dependencies (this may take a while)..."
# --- CONDA CONFLICT WORKAROUND ---
# Use a sanitized environment for pip to avoid conflicts with Conda/Miniconda.
env -u LD_LIBRARY_PATH PATH="/usr/bin:/bin:$PATH" "$PIP_PATH" install --no-cache-dir torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu126
env -u LD_LIBRARY_PATH PATH="/usr/bin:/bin:$PATH" "$PIP_PATH" install -r requirements.txt
# --- END WORKAROUND ---
echo "Python engine dependencies installed."

# 5. Node.js UI Setup
echo "--> Step 5: Setting up Node.js UI..."
cd "$INSTALL_DIR/ui"
echo "Installing Node.js dependencies in a sanitized environment..."
# --- NODE.JS VERSION CONFLICT WORKAROUND ---
# Force npm to use the correct Node.js version by prioritizing the system path.
env PATH="/usr/bin:$PATH" npm install
# --- END WORKAROUND ---
echo "Node.js UI dependencies installed."

# 6. Create the single systemd Service for the UI
echo "--> Step 6: Creating systemd service for the UI..."
sudo tee "/etc/systemd/system/$UI_SERVICE_NAME" > /dev/null <<EOF
[Unit]
Description=AI-Toolkit UI Service
After=network.target

[Service]
User=$USER
Group=$(id -gn $USER)
WorkingDirectory=$INSTALL_DIR/ui
# Use the full path to npm and the correct 'build_and_start' command.
ExecStart=/usr/bin/npm run build_and_start
Restart=always
RestartSec=10
# Set environment variables for the service.
Environment=PORT=$UI_PORT
Environment=AI_TOOLKIT_AUTH=$AUTH_TOKEN

[Install]
WantedBy=multi-user.target
EOF
echo "UI service file created."

# 7. Reload systemd and start the service
echo "--> Step 7: Reloading systemd and starting the UI service..."
sudo systemctl daemon-reload
sudo systemctl enable "$UI_SERVICE_NAME"
sudo systemctl start "$UI_SERVICE_NAME"

# 8. Final Status
echo "--- Installation Complete ---"
echo "The AI-Toolkit UI service has been started."
echo ""
echo "You can check its status with:"
echo "sudo systemctl status $UI_SERVICE_NAME"
echo ""
echo "The user interface should now be accessible on your network."
echo "Find your server's local IP address (e.g., using 'ip a' or 'hostname -I')."
echo "Then, open a web browser and navigate to: http://<YOUR_SERVER_IP>:$UI_PORT"
if [ -n "$AUTH_TOKEN" ]; then
    echo "You have set an authentication token. You will need it to log in."
fi

# Display the status to the user
echo "--- UI Service Status ---"
sudo systemctl status "$UI_SERVICE_NAME"
