#!/bin/bash
# Author: Ingmar Stapel / Enhanced by Assistant
# Date: 2025-02-25
# Version: 0.7
# This script installs n8n locally without Docker, configures it as a systemd service,
# installs PostgreSQL (if not already installed), creates the n8n database and a user,
# installs the pgvector extension, and installs/configures phppgadmin for easy database management.
# Exit immediately if any command exits with a non-zero status
set -e

### 1. System Update & Upgrade
sudo apt update && sudo apt upgrade -y

### 2. Install Node.js (if not already installed)
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

### 3. Install n8n Globally via npm
echo "Installing n8n globally..."
sudo npm i -g n8n

### 4. PostgreSQL Installation and Configuration
# Install PostgreSQL, development files, and build tools if not already installed
if ! command -v psql &> /dev/null; then
    echo "PostgreSQL not found. Installing PostgreSQL..."
    sudo apt-get install -y postgresql postgresql-contrib postgresql-server-dev-16 build-essential git
else
    echo "PostgreSQL is already installed."
fi

# Create PostgreSQL user and database if they don't already exist
# Adjust these variables as needed
DB_USER="ingmar"
DB_PASS="password123"
DB_NAME="n8n"

echo "Configuring PostgreSQL: creating user and database if not already present..."
sudo -u postgres psql <<EOF
DO
\$do\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER}') THEN
      CREATE ROLE ${DB_USER} WITH LOGIN PASSWORD '${DB_PASS}';
   END IF;
END
\$do\$;

-- Create database only if it does not exist
DO
\$do\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '${DB_NAME}') THEN
      CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
   END IF;
END
\$do\$;
EOF

### 5. Install pgvector Extension
# Clone, build, and install pgvector if it is not already available
if [ ! -f "/usr/share/postgresql/16/extension/vector.control" ]; then
    echo "Installing pgvector extension..."
    git clone https://github.com/pgvector/pgvector.git
    cd pgvector
    make
    sudo make install
    cd ..
    rm -rf pgvector
    # Restart PostgreSQL to load the new extension files
    sudo systemctl restart postgresql
else
    echo "pgvector extension already installed."
fi

# Create the extension in the n8n database
echo "Creating pgvector extension in the database..."
sudo -u postgres psql -d ${DB_NAME} -c "CREATE EXTENSION IF NOT EXISTS vector;"

### 6. Configure n8n as a systemd Service
# Retrieve the server's IP address
server_ip=$(hostname -I | awk '{print $1}')
echo "Found IP address: $server_ip"

# Configure n8n systemd service
echo "Configuring n8n as a systemd service..."
SERVICE_FILE="/etc/systemd/system/n8n.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=n8n - Workflow Automation Tool
After=network.target

[Service]
Type=simple
Environment="N8N_HOST=$server_ip"
Environment="NODE_ENV=production"
Environment="N8N_BASIC_AUTH_ACTIVE=true"
Environment="N8N_BASIC_AUTH_USER=admin"
Environment="N8N_BASIC_AUTH_PASSWORD=password123"
Environment="N8N_SECURE_COOKIE=false"
ExecStart=/usr/bin/env n8n
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOL

### 7. Reload and Start the n8n Service
sudo systemctl daemon-reload
sudo systemctl enable n8n
sudo systemctl start n8n
sudo systemctl status n8n

echo "n8n has been installed and configured as a systemd service."
echo "Access n8n at: http://$server_ip:5678"
echo "Username: admin"
echo "Password: password123"

### 8. Install and Configure phppgadmin for PostgreSQL Management
echo "Installing phppgadmin and required packages..."
sudo apt-get install -y phppgadmin apache2 php libapache2-mod-php

# By default, phppgadmin’s Apache configuration restricts access to localhost.
# Modify the configuration to allow access from any host.
PHPPGADMIN_CONF="/etc/apache2/conf-available/phppgadmin.conf"
if [ -f "$PHPPGADMIN_CONF" ]; then
    echo "Configuring phppgadmin for remote access..."
    sudo sed -i "s/Require local/Require all granted/" "$PHPPGADMIN_CONF"
    # In some cases, you might need to adjust further Apache settings.
fi

# Restart Apache to apply the changes
sudo systemctl restart apache2

echo "phppgadmin has been installed and configured."
echo "You can access phppgadmin at: http://$server_ip/phppgadmin"
echo "Use your PostgreSQL credentials to log in (e.g., username: ingmar, password: password123)."
