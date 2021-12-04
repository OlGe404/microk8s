#!/bin/bash

# NOTE: this file is used to install the tools and packages 
# needed to execute and test the playbook on ubuntu.
# because microk8s is only available for ubuntu, 
# it is the only case considered here.

REPO_ROOT_DIR=$(git rev-parse --show-toplevel)

sudo apt-get update
sudo apt-get install -y \
    python3-pip \
    python3-venv \
    libssl-dev \
    virtualbox

python3 -m pip install --quiet selinux

python3 -m pip install --user --quiet \
    "pyyaml<6,>=5.1" \
    ansible \
    openshift \
    jsonpatch

ansible-galaxy collection install -r $REPO_ROOT_DIR/ansible/requirements.yaml

if vagrant --version > /dev/null 2>&1 ; then
    echo -e "\n======> Skipping Vagrant installation, because it is already installed. \n"
else
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install vagrant
fi

ANSIBLE_VERSION=$(ansible --version | head -1 | awk '{print $3}' | tr -d ']')

python3 -m venv molecule && source molecule/bin/activate
python3 -m pip install --quiet \
    wheel \
    "pyyaml<6,>=5.1" \
    ansible \
    openshift \
    jsonpatch \
    python-vagrant \
    pytest-testinfra \
    molecule \
    molecule-vagrant \
    yamllint \
    ansible-lint

cat << EOF

======> pip packages: 
$(pip freeze)

======> molecule location: $(which molecule)
======> molecule version: $(molecule --version)

EOF

sudo apt-get autoclean && sudo apt-get autoremove -y
