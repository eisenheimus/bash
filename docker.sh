#!/bin/bash
set -e

# Update package index and install dependencies
apt update && apt install -y ca-certificates curl gnupg

# Create directory for keyrings
install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Install Docker Engine and plugins
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker service, add user to docker group
systemctl enable --now docker
if [ -n "${SUDO_USER}" ]; then
    usermod -aG docker "${SUDO_USER}" 2>/dev/null || true
fi

echo "Docker installed successfully."