#!/bin/bash

USER=$(whoami)

sudo snap remove microk8s
sudo rm -f ~/.kube/microk8s_config
sudo gpasswd -d $USER microk8s
sudo groupdel microk8s