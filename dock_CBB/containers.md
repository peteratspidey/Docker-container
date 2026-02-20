# containers implement
## create an environment directory 
to keep configuration files
```bash
mkdir ~/shigella-docker-env
cd ~/shigella-docker-env
```

## create a .yml file (tool list)
These files tell Docker which tools and packages are needed to install into the container environment
```bash
nano environment.yml
```
> This tells the container which tools to install 
## paste this into the tool list file 
```yaml
name: shigella-env
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - mamba
  - python=3.10
  - fastqc=0.11.9
  - trimmomatic=0.39
  - spades=3.15.5
  - prokka=1.14.6
  - mlst=2.23.0
  - abricate=1.0.1
  - ncbi-amrfinderplus=3.10.24
  - samtools=1.17
  - bwa=0.7.17
  - biopython
  - pandas
  - multiqc
```
save this `ctrl + o `, enter
close `ctrl + x`
This environment file lists all the tools u need and will be used inside the container
## create a Docker file 
this define how Docker builds ur custom image
```bash
nano Dockerfile
```
## paste this into docker file
```Dockerfile
FROM mambaorg/micromamba:1.5.0

# Copy environment definition
COPY environment.yml /tmp/environment.yml

# Create the conda/mamba environment
RUN micromamba create -y -n shigella-env -f /tmp/environment.yml && \
    micromamba clean --all --yes

# Enable automatic environment activation
# set the container to automatically load the environment when it starts
ENV MAMBA_DOCKERFILE_ACTIVATE=1
ENV PATH="/opt/conda/envs/shigella-env/bin:${PATH}"

# Default entrypoint
ENTRYPOINT ["/bin/bash"]
```
> This will create a Linux container, install the mamba environment, and buildthe  workflow environment
Save and exit

## build docker image
```bash
docker build -t shigella-env:1.0.
```
## exit container 
```bash
exit
```
# run tools

## run the Docker environment
```bash
docker run -it --rm shigella-env:1.0
```

## run the tools on real data
```bash
docker run -it \
   -v /home/peter/shigella_data:/data \
   shigella-env:1.0
```
