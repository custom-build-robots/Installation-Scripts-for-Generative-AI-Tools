# Installation Scripts for Generative AI Tools on Ubuntu

This repository contains a collection of shell scripts designed to automate the installation and configuration of popular generative AI tools and workflow automation platforms on Ubuntu. These scripts streamline the setup process, making it easy to deploy and run cutting-edge AI tools and interfaces.

---

## Scripts Overview

### 1. `install_Flowise.sh`
- **Purpose**: Installs and configures Flowise, a visual interface for building and managing AI workflows.
- **Details**:
  - Installs Flowise globally using `npm`.
  - Configures it as a systemd service for automatic startup.
  - Runs Flowise on a specified port (`3001`) and makes it accessible over the local network.

### 2. `install_n8n.sh`
- **Purpose**: Installs and configures n8n, a powerful workflow automation tool with integrations for AI-based solutions.
- **Details**:
  - Installs n8n globally using `npm`.
  - Sets up n8n as a systemd service for persistent execution.
  - Secures access with basic authentication and enables network-wide availability for AI-enhanced automation.

### 3. `install_ollama.sh`
- **Purpose**: Installs Ollama, a versatile platform for running and managing generative AI language models locally.
- **Details**:
  - Installs the latest version of Ollama, preparing your system to leverage advanced AI models like LLaMA.
  - Enables local deployment of AI models without relying on cloud infrastructure.

### 4. `install_ollama_web_ui.sh`
- **Purpose**: Deploys the Open Web UI for Ollama, providing a browser-based interface for interacting with generative AI models.
- **Details**:
  - Installs and configures the Open Web UI with support for Ollama models.
  - Makes the web interface accessible over the local network for seamless AI model management and interaction.

### 5. `ubuntu_install.sh`
- **Purpose**: Prepares your Ubuntu system with essential tools and dependencies for generative AI tools and development.
- **Details**:
  - Updates and upgrades system packages.
  - Installs common utilities and developer tools like `mc` and `curl`.
  - Ensures the system is ready for advanced AI installations and configurations.

---

## How to Use

1. Clone the repository to your Ubuntu system:
   ```bash
   git clone https://github.com/<your-username>/<repository-name>.git
   cd <repository-name>
2. Make the scripts executable:
   ```bash
   chmod +x *.sh

3. Run the desired script:
   ```bash
   ./install_Flowise.sh

---

### Contributing
Contributions are welcome! If you discover any issues or have ideas for improvement, feel free to open an issue or submit a pull request.

---

### License
This project is licensed under the MIT License. See the LICENSE file for details.
