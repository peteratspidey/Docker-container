#!/usr/bin/env bash

set -Eeuo pipefail

readonly IMAGE="ubuntu:26.04"
readonly CONTAINER_NAME="${1:-ubuntu-26-04}"

if ! command -v apt >/dev/null 2>&1; then
    echo "Error: this script requires an Ubuntu or Debian-based host with apt." >&2
    exit 1
fi

echo "Updating the package index..."
sudo apt update

if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker..."
    sudo apt install -y docker.io
else
    echo "Docker is already installed."
fi

echo "Enabling and starting Docker..."
sudo systemctl enable --now docker

echo "Pulling ${IMAGE}..."
sudo docker pull "${IMAGE}"

if sudo docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
    echo "Container '${CONTAINER_NAME}' already exists; starting it if necessary..."
    sudo docker start "${CONTAINER_NAME}" >/dev/null
else
    echo "Creating container '${CONTAINER_NAME}'..."
    sudo docker run -dit --name "${CONTAINER_NAME}" "${IMAGE}" bash
fi

echo
echo "Ubuntu 26.04 container '${CONTAINER_NAME}' is ready."
echo "Open a shell with: sudo docker exec -it ${CONTAINER_NAME} bash"
