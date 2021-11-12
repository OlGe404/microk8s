#!/bin/bash

ROLE=${1:-install}

python3 -m venv molecule && source molecule/bin/activate && \
cd roles/$ROLE && molecule verify