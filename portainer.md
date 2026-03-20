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
