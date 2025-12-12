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
