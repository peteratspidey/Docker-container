# installation steps for the docker as per the need for the bioinformatics tools
## remove the old installed versions of docker with other files
```bash
sudo apt remove docker docker-engine docker.io containerd runc
```
> this will remove old installed docker and its run time components

## now update the packages 
```bash
sudo apt update && sudo apt upgrade -y
```
## install the required packages
```bash
