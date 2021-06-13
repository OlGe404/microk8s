#!/bin/bash

USER=$(whoami)

sudo snap remove microk8s && \
sudo gpasswd -d $USER microk8s && \
sudo groupdel microk8s