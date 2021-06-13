#!/bin/bash

# this file is used to install all tools and packages needed to execute and test the ansible-playbook on ubuntu.
# because microk8s is only available for ubuntu, it is the only distro considered here.

sudo apt-get update

### docker setup
if docker --version > /dev/null 2>&1 ; then
    echo -e "\n======> Skipping Docker installation, because it already is installed. \n"
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
### docker setup

### ansible, vagrant and molecule setup
sudo apt-get install -y \
    python3-pip \
    python3-venv \
    libssl-dev

if ansible --version > /dev/null 2>&1 ; then
    echo -e "\n======> Skipping Ansible installation, because it already is installed. \n"
else
    sudo apt-get install -y ansible
fi

if vagrant --version > /dev/null 2>&1 ; then
    echo -e "\n======> Skipping Vagrant installation, because it already is installed. \n"
else
    sudo apt-get install -y vagrant
fi
    
ANSIBLE_VERSION=$(ansible --version | head -1 | awk '{print $2}')

python3 -m venv molecule && source molecule/bin/activate
python3 -m pip install wheel \
    ansible==$ANSIBLE_VERSION \
    python-vagrant \
    testinfra \
    molecule \
    molecule-vagrant

cat << EOF

======> Vagrant location: $(which vagrant)
======> Vagrant version: $(vagrant --version)

======> molecule location: $(which molecule)
======> molecule version: $(molecule --version)

EOF
### ansible, vagrant and molecule setup

sudo apt-get autoclean && sudo apt-get autoremove