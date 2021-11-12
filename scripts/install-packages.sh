#!/bin/bash

# NOTE: this file is used to install the tools and packages 
# needed to execute and test the playbook on ubuntu.
# because microk8s is only available for ubuntu, 
# it is the only case considered here.

REPO_ROOT_DIR=$(git rev-parse --show-toplevel)

sudo apt-get update

### ansible, vagrant and molecule setup
sudo apt-get install -y \
    python3-pip \
    python3-venv \
    libssl-dev \
    virtualbox

if ansible --version > /dev/null 2>&1 ; then
    echo -e "\n======> Skipping Ansible installation, because it already is installed. \n"
else
    sudo apt-get install -y ansible
fi

ANSIBLE_VERSION=$(ansible --version | head -1 | awk '{print $2}')

# with ansible 2.9.x, there is a bug where
# newer version of kubernetes and openshift
# won't work with the kubenetes.core module
# so the working versions are fixated in that case
if [[ $ANSIBLE_VERSION == *"2.9"* ]] ; then
    python3 -m pip install \
        "kubernetes==11.0.0" \
        "openshift<0.12"
else 
    python3 -m pip install \
        "kubernetes" \
        "openshift"
fi

ansible-galaxy collection install -r $REPO_ROOT_DIR/requirements.yaml

if vagrant --version > /dev/null 2>&1 ; then
    echo -e "\n======> Skipping Vagrant installation, because it already is installed. \n"
else
    sudo apt-get install -y vagrant
fi

python3 -m venv molecule && source molecule/bin/activate
python3 -m pip install \
    wheel \
    "pyyaml<6" \
    ansible==$ANSIBLE_VERSION \
    python-vagrant \
    pytest-testinfra \
    molecule \
    molecule-vagrant \
    yamllint \
    ansible-lint

cat << EOF

======> Vagrant location: $(which vagrant)
======> Vagrant version: $(vagrant --version)

======> molecule location: $(which molecule)
======> molecule version: $(molecule --version)

EOF

sudo apt-get autoclean && sudo apt-get autoremove -y
