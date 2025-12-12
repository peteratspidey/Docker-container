# containers implement
## create a environment directory 
```bash
mkdir ~/shigella-docker-env
cd ~/shigella-docker-env
```

## create a .yml file (tool list)
```bash
nano environment.yml
```
> this tells container to which tools to be installed 
## paste this into tool list file 
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

## create a docker file 
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
ENV MAMBA_DOCKERFILE_ACTIVATE=1
ENV PATH="/opt/conda/envs/shigella-env/bin:${PATH}"

# Default entrypoint
ENTRYPOINT ["/bin/bash"]
```
> this will creates a linux container , install mamba environment and build workflow environment
save and exit

## build docker image
```bash
docker build -t shigella-env:1.0 .
```
## exit container 
```bash
exit
```
# run tools
## run the tools on real data
```bash
docker run -it \
   -v /home/peter/shigella_data:/data \
   shigella-env:1.0
```
