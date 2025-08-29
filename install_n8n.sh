#!/bin/bash
# Author: Ingmar Stapel / Enhanced by Gemini
# Date: 2025-08-29
# Version: 2.0 FINAL
# Description: This script installs or updates n8n reliably.
# It automatically finds the n8n binary after installation/update and links it correctly.
#
# Usage:
#   For a new installation: sudo ./manage_n8n.sh install
#   To update an existing installation: sudo ./manage_n8n.sh update

set -e

# --- Configuration Variables ---
DB_USER="ingmar"
DB_PASS="password123"
DB_NAME="n8n"

# =================================================================
# HELPER FUNCTION: Find and link the n8n binary
# =================================================================
find_and_link_n8n() {
    echo "Searching for n8n executable..."
    # Find the executable, exclude paths that are already links to avoid loops
    N8N_EXECUTABLE_PATH=$(find /usr/lib/node_modules /usr/local/lib/node_modules -name "n8n" -type f -executable -not -type l | head -n 1)

    if [ -z "$N8N_EXECUTABLE_PATH" ]; then
        echo "❌ ERROR: n8n executable not found after installation."
        exit 1
    fi

    echo "Found n8n at: $N8N_EXECUTABLE_PATH"
    echo "Creating stable symlink at /usr/local/bin/n8n..."
    # Remove old link/file and create a new, correct one
    sudo rm -f /usr/local/bin/n8n
    sudo ln -s "$N8N_EXECUTABLE_PATH" /usr/local/bin/n8n
    echo "Symlink created successfully."
}


# =================================================================
# UPDATE FUNCTION
# =================================================================
update_n8n() {
    echo "--- Starting n8n Update ---"
    echo "1. Stopping n8n service..."
    sudo systemctl stop n8n || true

    echo "2. Removing old n8n installations..."
    sudo rm -rf /usr/local/lib/node_modules/n8n
    sudo rm -rf /usr/lib/node_modules/n8n

    echo "3. Clearing npm cache..."
    sudo npm cache clean --force

    echo "4. Installing latest version of n8n..."
    sudo npm install -g n8n@latest

    echo "5. Locating and linking new n8n binary..."
    find_and_link_n8n # <--- WICHTIGE NEUE ZEILE

    echo "6. Reloading and restarting service..."
    sudo systemctl daemon-reload
    sudo systemctl start n8n

    echo "7. Verifying new version..."
    sleep 5
    new_version=$(n8n --version)
    echo "✅ Update complete. New n8n version is: $new_version"
}

# =================================================================
# INSTALL FUNCTION
# =================================================================
install_n8n() {
    echo "--- Starting New n8n Installation ---"
    ### 1. System & Node.js
    sudo apt update && sudo apt upgrade -y
    if ! command -v node &> /dev/null; then sudo apt-get install -y nodejs npm; else echo "Node.js ready."; fi

    ### 2. Install n8n & Link Binary
    echo "Installing n8n..."
    sudo npm i -g n8n
    find_and_link_n8n # <--- WICHTIGE NEUE ZEILE

    ### 3. PostgreSQL
    if ! command -v psql &> /dev/null; then sudo apt-get install -y postgresql postgresql-contrib postgresql-server-dev-$(pg_config --version | cut -d ' ' -f 2 | cut -d . -f 1) build-essential git; else echo "PostgreSQL ready."; fi
    sudo -u postgres psql -c "CREATE ROLE ${DB_USER} WITH LOGIN PASSWORD '${DB_PASS}';" || echo "User ${DB_USER} already exists."
    sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};" || echo "Database ${DB_NAME} already exists."

    ### 4. pgvector
    PG_VERSION=$(pg_config --version | cut -d ' ' -f 2 | cut -d . -f 1)
    if [ ! -f "/usr/share/postgresql/${PG_VERSION}/extension/vector.control" ]; then
        git clone https://github.com/pgvector/pgvector.git; cd pgvector; make; sudo make install; cd ..; rm -rf pgvector; sudo systemctl restart postgresql
    fi
    sudo -u postgres psql -d "${DB_NAME}" -c "CREATE EXTENSION IF NOT EXISTS vector;"

    ### 5. Configure n8n systemd Service
    server_ip=$(hostname -I | awk '{print $1}')
    SERVICE_FILE="/etc/systemd/system/n8n.service"
    sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=n8n - Workflow Automation Tool
After=network.target postgresql.service

[Service]
Type=simple
User=$(whoami)
# This path is now stable thanks to our symlink
ExecStart=/usr/local/bin/n8n 
Restart=always
Environment="NODE_ENV=production"
Environment="N8N_HOST=${server_ip}"
Environment="N8N_PORT=5678" 
# --- PostgreSQL Configuration ---
Environment="DB_TYPE=postgresdb"
Environment="DB_POSTGRESDB_HOST=localhost"
Environment="DB_POSTGRESDB_PORT=5432"
Environment="DB_POSTGRESDB_DATABASE=${DB_NAME}"
Environment="DB_POSTGRESDB_USER=${DB_USER}"
Environment="DB_POSTGRESDB_PASSWORD=${DB_PASS}"

[Install]
WantedBy=multi-user.target
EOL

    ### 6. Reload and Start n8n
    sudo systemctl daemon-reload
    sudo systemctl enable n8n
    sudo systemctl start n8n
    
    echo "✅ n8n installed and configured with PostgreSQL."
    echo "Access n8n at: http://${server_ip}:5678"
}

# =================================================================
# MAIN SCRIPT LOGIC
# =================================================================
if [ "$1" == "install" ]; then
    install_n8n
elif [ "$1" == "update" ]; then
    update_n8n
else
    echo "Error: Invalid argument."
    echo "Usage: $0 {install|update}"
    exit 1
fi
