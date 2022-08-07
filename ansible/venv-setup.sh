#!/bin/bash
set -o pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

cd "$REPO_ROOT"

python3 -m venv ansible/.venv && source ansible/.venv/bin/activate
python3 -m pip install --upgrade pip wheel
python3 -m pip install --requirement "$REPO_ROOT"/ansible/requirements.txt

cat <<EOF

##### Installed pip packages:
$(python3 -m pip freeze)

EOF

ansible-galaxy collection install -r ansible/requirements.yaml  --upgrade

cat <<EOF

##### ansible-galaxy installations:
$(cat ansible/requirements.yaml)

EOF
