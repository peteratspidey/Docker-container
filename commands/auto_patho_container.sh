#!/bin/bash

set -e

echo "======================================"
echo " Docker container installation "
echo "======================================"

# -------------------------------
# 1. System Update
# -------------------------------
sudo apt update && sudo apt upgrade -y

# -------------------------------
# 2. Install Docker
# -------------------------------
if ! command -v docker &> /dev/null
then
    sudo apt install -y docker.io
fi

# -------------------------------
# 3. Start Docker
# -------------------------------
sudo systemctl enable docker
sudo systemctl start docker

# -------------------------------
# 4. Optional: future permission
# -------------------------------
sudo usermod -aG docker $USER

# -------------------------------
# 5. Ask container name
# -------------------------------
DEFAULT_NAME="docker_initial"
read -p "Enter container name [default: $DEFAULT_NAME]: " NAME
CONTAINER_NAME=${NAME:-$DEFAULT_NAME}

echo "Using container: $CONTAINER_NAME"

# -------------------------------
# 6. Pull image & run container
# -------------------------------
sudo docker pull ubuntu:25.10

sudo docker run -dit --name "$CONTAINER_NAME" ubuntu:25.10

# -------------------------------
# 7. Install inside container
# -------------------------------
sudo docker exec "$CONTAINER_NAME" bash -c "
apt update && apt upgrade -y && \
apt install -y \
    curl wget unzip zip tar gzip pigz \
    git tree jq \
    ca-certificates build-essential nano \
    python3 python3-pip python3-venv \
    python3-matplotlib python3-pandas \
    net-tools htop tmux screen \
    parallel \
    ncbi-blast+ \
    emboss \
    perl \
    liblist-moreutils-perl \
    libjson-perl \
    libtext-csv-perl \
    libpath-tiny-perl \
    libfile-slurp-perl \
    libwww-perl \
    libmoo-perl \
    libnamespace-clean-perl \
    libsub-quote-perl \
    librole-tiny-perl \
    libclass-method-modifiers-perl \
    libmodule-runtime-perl && \

# ---- Clone MLST ----
cd /root && \
git clone https://github.com/tseemann/mlst.git && \

# ---- Set PERL5LIB ----
echo 'export PERL5LIB=/root/mlst/perl5:\$PERL5LIB' >> /root/.bashrc && \

# ---- Make MLST globally accessible ----
ln -s /root/mlst/bin/mlst /usr/local/bin/mlst
"

# -------------------------------
# 8. Enter container
# -------------------------------
echo "======================================"
echo "Entering container: $CONTAINER_NAME"
echo "======================================"

sudo docker exec -it "$CONTAINER_NAME" bash
