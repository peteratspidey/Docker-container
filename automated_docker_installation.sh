#!/bin/bash

set -e

echo "======================================"
echo " Docker container installation "
echo "======================================"

# -------------------------------
# 1. System Update
# -------------------------------
sudo apt update && sudo apt upgrade -y

# -------------------------------
# 2. Install Docker
# -------------------------------
if ! command -v docker &> /dev/null
then
    sudo apt install -y docker.io
fi

# -------------------------------
# 3. Start Docker
# -------------------------------
sudo systemctl enable docker
sudo systemctl start docker

# -------------------------------
# 4. Optional: future permission
# -------------------------------
sudo usermod -aG docker $USER

# -------------------------------
# 5. Ask container name
# -------------------------------
DEFAULT_NAME="docker_initial"
read -p "Enter container name [default: $DEFAULT_NAME]: " NAME
CONTAINER_NAME=${NAME:-$DEFAULT_NAME}

echo "Using container: $CONTAINER_NAME"

# -------------------------------
# 6. Pull image & run container
# -------------------------------
sudo docker pull ubuntu:25.10

sudo docker run -dit --name "$CONTAINER_NAME" ubuntu:25.10

# -------------------------------
# 7. Install inside container
# -------------------------------
sudo docker exec "$CONTAINER_NAME" bash -c "
apt update && apt upgrade -y && \
apt install -y \
    curl unzip zip tar gzip git \
    ca-certificates build-essential nano \
    python3 python3-pip python3-venv net-tools
"

# -------------------------------
# 8. Enter container
# -------------------------------
echo "======================================"
echo "Entering container: $CONTAINER_NAME"
echo "======================================"

sudo docker exec -it "$CONTAINER_NAME" bash
