#!/bin/bash

sudo apt install python3-pip -y
sudo snap install helm --classic
helm plugin install https://github.com/databus23/helm-diff --version v3.9.6
python3 -m pip install --upgrade --user -r requirements.txt
ansible-galaxy collection install -r requirements.yaml
