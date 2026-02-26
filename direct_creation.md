# create directly 
## update the system
```bash
sudo apt update
```
## install docker.io
```bash
sudo apt instal docker.io
```
## enable docker from the systemctl service 
```bash
sudo systemctl enable docker
```
## start the docker in systemctl service
```bash
sudo systemctl start docker
```

## removing sudo application on each start up
```bash
sudo usermod -aG docker $USER
```
> this will add user to the docker group so that it wont ask for the sudo password everytime

## start new updated session 
```bash
newusr docker
```
> the usermod doesnot apply immediately , for that we need to logout and login -> instead we use `newusr docker`
> 
