#!/bin/bash

# this file is used to install all tools and packages needed to execute and test the ansible-playbook on ubuntu.
# because microk8s is only available for ubuntu, it is the only distro considered here.

# docker GPG key and repository setup
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update && \
sudo apt install -y python3-pip \
    libssl-dev \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    docker-ce \
    docker-ce-cli \
    containerd.io
sudo apt-get clean

# setup to use docker as a non-root user
sudo groupadd docker && \
sudo usermod -aG docker $(whoami) && \
newgrp docker

# molecule
python3 -m pip install --user "molecule[docker,lint]"