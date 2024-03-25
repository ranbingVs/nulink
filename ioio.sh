#!/bin/bash

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install ionet setup script
curl -L https://github.com/ionet-official/io-net-official-setup-script/raw/main/ionet-setup.sh -o ionet-setup.sh
chmod +x ionet-setup.sh && ./ionet-setup.sh

# Install curl if not already installed
sudo apt install -y curl

# Download and make the launch binary executable
curl -L https://github.com/ionet-official/io_launch_binaries/raw/main/launch_binary_linux -o launch_binary_linux
chmod +x launch_binary_linux

# Optional: Display a message indicating completion
echo "Setup completed successfully."
