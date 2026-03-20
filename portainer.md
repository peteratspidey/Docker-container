# portainer
lighweight web UI for managing docker containers,images,volumes and networks
# installation steps of portainer for handling containers in GUI
## check the docker installation and running 
```bash
docker --version \
sudo systemctl status docker
```
## create a volume for portainer in docker 
```bash
docker volume create portainer_data
```
> this volumes persists users, settings , endpoints.
> without this data will be lost

## installation commands
```bash
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```
> `-d` run docker in detached mode
> `-p 8000:8000` is the link of the port for agent communication
>  `-p 9443:9443` - HTTPS web UI access , will open this in brower
> `--name portainer ` is the name of the portainer
>  `--restart=always` - restarts after reboot
> `-v /var/run/docker.sock:/var/docker.sock` - critical mount , give access portainer to docker (portainer control docker
> `-v portainer_data:/data` - mounts persistent storage volume
> `portainer/portainer-ce:latest` - official image from docker hub

## verify portainer container creation
```bash
docker ps -a 
```
> u will see a container with name portianer:ce

## access portainer UI
```
https://localhost:9443
```
or replace the ip for the your system
```
https://<your_ip>9443
```
## it will ask for username and pass 
> create for own use
> 
