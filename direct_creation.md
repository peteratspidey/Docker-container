# create directly 
## update the system
```bash
sudo apt update
```
## install docker.io
```bash
sudo apt install docker.io
```
## enable Docker from the systemctl service 
```bash
sudo systemctl enable docker
```
## start the Docker in the systemctl service
```bash
sudo systemctl start docker
```

## removing sudo application on each start up
```bash
sudo usermod -aG docker $USER
```
> This will add the user to the Docker group so that it won't ask for the sudo password every time

## start new updated session 
```bash
newusr docker
```
> The usermod does not apply immediately, for that we need to log out and log in -> instead we use `newusr docker`

## pull image directly 
```bash
docker pull ubuntu:22.04
```

## run the interactive container with a name
```bash
docker run -it --name ubuntu-dev ubuntu:22.04
```

## open the container again (only container name needed)
```bash
docker exec -it <container_name> bash
```
> Example: `docker exec -it ubuntu-dev bash`

## check container names
```bash
docker ps -a
```
> This shows your container names so you can use them directly with `docker exec`.

## to install other tools that might require run this (run this inside the container)
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
software-properties common \
python3 \
python3-pip \
python3-venv \
net-tools \
```
