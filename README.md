# Installation Scripts for Generative AI Tools on Ubuntu

This repository contains a collection of shell scripts designed to automate the installation and configuration of popular generative AI tools and workflow automation platforms on Ubuntu. These scripts streamline the setup process, making it easy to deploy and run cutting-edge AI tools and interfaces.

---

## About the Author

Visit my blog [AI Box](https://ai-box.eu), where I write about AI, generative AI tools, and their applications in the real world. It’s a hub for AI enthusiasts looking to explore and understand the latest advancements in artificial intelligence.

---

## Important Note on Docker Usage

While Docker is widely recognized as a powerful and flexible tool for containerized deployments, only the `install_ollama_web_ui.sh` script uses Docker. This is because, for the other tools, Docker's internal network configuration posed challenges in making them accessible over the local network to other users and PCs for the autor. 

For tools like Flowise, n8n, and Ollama, the scripts use local installations without Docker to ensure they are exposed directly to your intranet, providing seamless access for all devices within the same local network.

Docker is still leveraged for the Ollama Web UI installation, where its features align perfectly with the requirements of that specific tool.

If you'd like to adapt these scripts to run all tools in Docker containers, I would be thrilled to see your contributions and ideas!

---

## Scripts Overview

### 1. `install_ubuntu.sh`
- **Purpose**: Prepares your Ubuntu system with essential tools and dependencies for generative AI tools and development.
- **Hint**: The installation methods used in these scripts assume that your system is equipped with a NVIDIA RTX graphics card like a RTX 4090, A6000 or even better.
- **Details**:
  - Updates and upgrades system packages.
  - Installs common utilities and developer tools like `mc` and `curl`.
  - Ensures the system is ready for advanced AI installations and configurations.

### 2. `install_ollama.sh`
- **Purpose**: Installs Ollama, a versatile platform for running and managing generative AI language models locally.
- **Details**:
  - Installs the latest version of Ollama, preparing your system to leverage advanced AI models like LLaMA.
  - Enables local deployment of AI models without relying on cloud infrastructure.

### 3. `install_ollama_web_ui.sh`
- **Purpose**: Deploys the Open Web UI for Ollama, providing a browser-based interface for interacting with generative AI models.
- **Details**:
  - Installs and configures the Open Web UI with support for Ollama models.
  - Makes the web interface accessible over the local network for seamless AI model management and interaction.

### 4. `install_n8n.sh`
- **Purpose**: Installs and configures n8n, a powerful workflow automation tool with integrations for AI-based solutions.
- **Details**:
  - Installs n8n globally using `npm`.
  - Sets up n8n as a systemd service for persistent execution.
  - Secures access with basic authentication and enables network-wide availability for AI-enhanced automation.

### 5. `install_Flowise.sh`
- **Purpose**: Installs and configures Flowise, a visual interface for building and managing AI workflows.
- **Details**:
  - Installs Flowise globally using `npm`.
  - Configures it as a systemd service for automatic startup.
  - Runs Flowise on a specified port (`3001`) and makes it accessible over the local network.

### 6. `install_whisper_offline.sh`  
   **Purpose**: Installs OpenAI's Whisper project for offline speech-to-text transcription.  
   **Details**:
   - Sets up Whisper in an isolated Python virtual environment for offline usage.
   - Downloads and installs dependencies locally.
   - Fetches and configures the Whisper base model for transcription tasks.
   - Ensures the system is ready for running Whisper without requiring an internet connection.
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

## Using `systemctl` Commands

After modifying or updating any of the service-related scripts (e.g., changing ports or configurations), it’s important to ensure the changes are applied to the respective systemd service. Use the following commands:

1. **Reload the systemd manager configuration**:
   ```bash
   sudo systemctl daemon-reload

This ensures that systemd recognizes any changes made to the service files.

2. **Restart the specific service**:

   ```bash
   sudo systemctl restart flowise
   
Replace flowise with the name of the service you are restarting (e.g., n8n or ollama).

3. **Check the status of the service**:

   ```bash
   sudo systemctl status flowise
   
This displays the current status of the service, including whether it is running, any errors encountered, and recent log output.


By following these steps, you can ensure that the latest changes to your service configurations take effect.

---

### Contributing
Contributions are welcome! If you discover any issues or have ideas for improvement, feel free to open an issue or submit a pull request.

---

### License
This project is licensed under the MIT License. See the LICENSE file for details.
