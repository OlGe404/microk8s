#!/bin/bash

# NOTE: docker is not needed to run microk8s in any form.
# if you only want to deploy on microk8s, there is no need
# to run this script to install docker-ce.

sudo apt-get update

if docker --version > /dev/null 2>&1 ; then
    echo -e "\n======> Skipping Docker installation, because it is already installed. \n"
else 
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io

    sudo groupadd docker && \
    sudo usermod -aG docker $(whoami) && \
    newgrp docker
fi

cat << EOF

======> Docker location: $(which docker)
======> Docker version: $(docker --version)

EOF

sudo apt-get autoclean && sudo apt-get autoremove -y 