# file operation to move data from container to machine and vice versa
## to move data from container to machine  ( from outside of the container)
```bash
docker cp <container_id>:<container_path> <machine_path>
```
`e:-`
```bash
docker cp <bidya_cbb:/home/<user>/<file_name.txt> ~/home/<user>/Downloads
```


## to save all the output to the host 
```bash
docker run -v $(pwd):/data -it image_name
```
## to migrate the docker container for 
### make an image of the docker container 
```bash
docker commit <container_name> mytool:latest
```
or
```bash
docker commit <container_id> mytool:latest
```

### change the tag (if want to )
```bash
docker tag <container_id> mytool:latest
```
> mytool is the repo name , latest is the tag

### now save the container image in tar to migrate
