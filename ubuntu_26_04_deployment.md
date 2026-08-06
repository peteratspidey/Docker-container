# Deploy an Ubuntu 26.04 Docker container

This guide installs Docker on an Ubuntu or Debian-based host, downloads the
official Ubuntu 26.04 image, and starts a container.

## Manual installation

Update the package index and install Docker:

```bash
sudo apt update
sudo apt install -y docker.io
```

Enable Docker at boot and start it now:

```bash
sudo systemctl enable --now docker
sudo docker --version
```

Pull the official Ubuntu 26.04 image:

```bash
sudo docker pull ubuntu:26.04
```

Create and start a container named `ubuntu-26-04`:

```bash
sudo docker run -dit --name ubuntu-26-04 ubuntu:26.04 bash
```

Open a shell inside the running container:

```bash
sudo docker exec -it ubuntu-26-04 bash
```

Inside the container, you can update packages and install common tools:

```bash
apt update
apt install -y curl git nano
```

Type `exit` to leave the container without stopping it.

## Useful container commands

```bash
# Show running containers
sudo docker ps

# Show all containers, including stopped ones
sudo docker ps -a

# Stop the container
sudo docker stop ubuntu-26-04

# Start it again
sudo docker start ubuntu-26-04

# Remove it after it has been stopped
sudo docker rm ubuntu-26-04
```

## Automated installation

The included script performs the installation, pulls the image, and creates the
container:

```bash
chmod +x deploy_ubuntu_26_04.sh
./deploy_ubuntu_26_04.sh
```

The script keeps using `sudo`, so it works immediately without requiring you to
log out and back in after changing Docker group membership.
