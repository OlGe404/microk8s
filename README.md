# Microk8s
This repo can be used to setup a local kubernetes installation based on microk8s.
Checkout https://microk8s.io/ for more information.

## Prerequisites
For general prerequisites of microk8s, see https://microk8s.io/docs/getting-started.

To fullfill the prerequisites for the automation in this repo, run these commands to install
the necessary packages and ansible collections:

```
python3 -m pip install --upgrade --user -r requirements.txt && \
ansible-galaxy collection install -r requirements.yaml
```

## Installation
Run the following commands to start the installation:
  * Start with <code>ansible-playbook install.yaml</code> and provide your sudo password
  * Refresh your groups with <code>newgrp microk8s</code>
  * Refresh your shell with <code>. /etc/profile.d/microk8s.sh</code>
  * Ensure the client works with <code>mkctl get pods --all-namespaces</code>

The UI will be available at <code>http://localhost:30001</code> after the installation.

### Start/Stop microk8s
After the installation, microk8s will be started but it won't be added to the autostart.

To start microk8s, run `microk8s start && microk8s status --wait-ready`. It can take some time
for all services to be ready/running and available via nodeports, ingresses etc. even after 
the command returns.

To stop microk8s, run `microk8s stop`.

See `microk8s help` for a list of all available subcommands.

### Bash aliases
The playbook creates aliases to ease the usage of `microk8s` and `microk8s kubectl` commands.
It also exports the `KUBECONFIG` env so you can work with other clients like oc/kubectl/helm etc.
as with any other kubernetes installation.

The following aliases are created:

| Alias | Command                                                         | Notes                                                                                |
| ----- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| mk8s  | `microk8s`                                                      | For commands controlling microk8s itself, e.g. `mk8s start` or `mk8s stop`           |
| mkctl | `microk8s kubectl`                                              | To run kubectl commands with the included binary, e.g. `mkctl get services`          |
| mkns  | `microk8s kubectl config set-context microk8s --namespace <ns>` | To set a namespace for subsequent microk8s kubectl commands, e.g. `mkns kube-system` |

## Deinstallation
To deinstall the microk8s environment, run <code>ansible-playbook deinstall.yaml</code>
and provide your sudo password when prompted.
