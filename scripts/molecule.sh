#!/bin/bash

REPO_ROOT_DIR=$(git rev-parse --show-toplevel)
CMD=${1:-test}
ROLE=${2:-microk8s}

cd $REPO_ROOT_DIR/ansible

python3 -m venv molecule && source molecule/bin/activate

cd $REPO_ROOT_DIR/ansible/roles/$ROLE && molecule $CMD
