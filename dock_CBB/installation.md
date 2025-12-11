# installation steps for Docker as per the need for the bioinformatics tools
## remove the old installed versions of Docker with other files
```bash
sudo apt remove docker docker-engine docker.io containerd runc
```
> This will remove the old installed Docker and its runtime components

## now update the packages 
```bash
sudo apt update && sudo apt upgrade -y
```
## install the required packages
```bash
sudo apt install -y curl ca-certificates gnupg lsb-release
```
> This will download the security and repo-handling packages for authenticity and safety for the installation of the packages or repo

## add docker official gpg keys 
```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

## add dokcer repo
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
## install docker engine
```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
## verify installtion 
```bash
sudo docker run hello-world
```
