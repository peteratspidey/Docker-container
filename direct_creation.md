# Create a Docker container directly

## Update the system

```bash
sudo apt update
```

## Install Docker

```bash
sudo apt install docker.io
```

## Enable and start Docker

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

## Run Docker without sudo

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

## Pull an image

```bash
docker pull ubuntu:22.04
```

## Create and run a named container

```bash
docker run -it --name ubuntu_container ubuntu:22.04
```

## List all containers

```bash
docker ps -a
```

## Rename a container

```bash
docker rename old_name new_name
```

## Start and stop a container

```bash
docker start ubuntu_container
docker stop ubuntu_container
```

## Open a terminal inside a running container

```bash
docker exec -it ubuntu_container bash
```

## Copy files between the computer and container

```bash
# Computer to container
docker cp file.txt ubuntu_container:/root/

# Container to computer
docker cp ubuntu_container:/root/file.txt ./
```

## Copy or move normal files

```bash
cp source.txt copy.txt
mv source.txt new_name.txt
```

## Install useful tools inside the container

```bash
apt update && apt install -y \
    gedit \
    curl \
    unzip \
    zip \
    tar \
    gzip \
    ca-certificates \
    build-essential \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv \
    net-tools
```
