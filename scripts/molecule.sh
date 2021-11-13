#!/bin/bash
# getopts

REPO_ROOT_DIR=$(git rev-parse --show-toplevel)
CMD=${1:-test}
ROLE=${2:-install}

python3 -m venv $REPO_ROOT_DIR/molecule && source $REPO_ROOT_DIR/molecule/bin/activate

cd $REPO_ROOT_DIR/roles/$ROLE && molecule $CMD