# isntall docker 
```bash
sudo apt update
sudp apt install docker.io docker-compose -y
```
 * `docker.io` - official docker public registry (docker hub)
 * installing this to get docker engine to - create & run containers , build images and pull images from docker hub

 * `docker-compose` - multi containers manager (optional but useful )
 
# enable and start docker
```bash
sudo systemctl enable docker
sudo systemctl start docker
```

# add urself to the docker group 
```bash
sudo usermod -aG docker $USER
```
