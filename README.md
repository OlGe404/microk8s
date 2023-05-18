# microk8s
This repo can be used to setup a local k8s environment for development and test purposes based on microk8s. Checkout https://microk8s.io/ for more information.

## Prerequisites
Before starting the installation, run these commands to install the necessary packages
and ansible collections:

```
python3 -m pip install --upgrade -r requirements.txt && \
ansible-galaxy collection install -r requirements.yaml
```

## Installation
Run the following commands to start the installation:
  * Start the installation with <code>ansible-playbook install.yaml</code> and provide your sudo password when prompted
  * After the installation has finished, refresh your groups with <code>newgrp microk8s</code>
  * List all running pods by <code>mkctl get pods --all-namespaces</code>

After the microk8s installation is done, the kubernetes-dashboard UI will be available at <code>http://localhost:30001</code>.

### Bash aliases
The playbook appends aliases to your ~/.bashrc file to ease the usage of 
`microk8s kubectl` and `microk8s` commands.

The following aliases are created:

| Alias | Command            | Notes                                           |
| ----- | ------------------ | ----------------------------------------------- |
| m8s   | `microk8s`         | For commands, e.g. `m8s start`                  |
| mkctl | `microk8s kubectl` | To query the k8s API, e.g. `mkctl get services` |

You can also use the regular oc/kubectl commands to interact with your cluster,
because the "KUBECONFIG" env for microk8s will be added to your $HOME/.bashrc file.

## Deinstallation
To deinstall the microk8s environment, run
  * <code>ansible-playbook deinstall.yaml</code> and provide your sudo password when prompted.
  * Remove the aliases and KUBECONFIG export from your $HOME/.bashrc file.
