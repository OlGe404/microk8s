# TL;DR
```bash
scripts/install-packages.sh && \
cd ansible && ansible-playbook install.yaml
```

# TOC
- [TL;DR](#tldr)
- [TOC](#toc)
- [Purpose](#purpose)
- [Usage](#usage)
  - [Testing](#testing)
  - [WebUI](#webui)
    - [Bash aliases](#bash-aliases)
  - [Known Issues](#known-issues)
- [Uninstall](#uninstall)

# Purpose
This repo is meant to be used for the installation and setup of a local k8s environment for development and test purposes.

The installation and setup is done with ansible to ensure a deterministic state on multiple installs. The playbook will edit, generate and deploy files to ensure a comprehensive experience with the local k8s environment:

* add the current user to the Microk8s group to interact with the Microk8s API as a non-root user
* append aliases for common `microk8s` commands to the ~/.bash_aliases file
* generate a ~/.kube/microk8s_config file to interact with the microk8s API without overwriting existing ~/.kube/config files
* deploy the k8s-dashboard as a WebUI for Microk8s

The default configuration will install Microk8s in its `latest/stable` version with the `rbac`, `dns` and `storage` add-ons enabled. Check out [Microk8s](https://microk8s.io) to learn more about the available features.

**Hint:** If you want to install a specific version of Microk8s or install additional add-ons by default, you can overwrite the default parameters via CLI when calling the playbook or by altering the [defaults/main.yaml file](ansible/roles/microk8s/defaults/main.yaml).

# Usage
To install the necessary tools and packages, run:

```bash
scripts/install-packages.sh
```

To setup the local k8s environment, run
```bash
cd ansible && ansible-playbook install.yaml
```

When the installation is done, you can query the Microk8s API via
```bash
mkgp --all-namespaces
```

**Hint:** You may need to (re)login or atleast refresh the groups for your user to interact with the k8s API. Run `su $(whoami)` or `newgrp microk8s` to do so.

## Testing
TL;DR: The `microk8s` role is tested with Ubuntu 21.10, 21.04, 20.04 LTS, 18.04 LTS and 16.04 LTS. See the [molecule config file](ansible/roles/microk8s/molecule/default/molecule.yml) for more details.

To ensure the Microk8s installation works on multiple Ubuntu versions, molecule is used. When running `scripts/molecule.sh`, molecule will bootstrap vagrant boxes with ubuntu 21.10, 21.04, 20.04 LTS, 18.04 LTS and 16.04 LTS to execute the `microk8s` role against them.

"But why does your molecule setup not run any verifier?" - because ansible is a fail fast, push based system. If the `microk8s` role can be executed successfully and passes the idempotency test, the installation steps are sufficiently tested and ready to use. There is no need to run additional verifiers, because ansible does the checks itself while applying them.

**Hint:** Run `scripts/install-packages.sh` before using molecule to ensure all packages are installed and the python virtual environment is setup and ready to use for the molecule test scenario.

## WebUI
After the Microk8s installation is done and the `k8s-dashboard` role was executed successfully, the WebUI will be available at `http://localhost:30001` in your Webbrowser.

### Bash aliases
The playbook appends aliases to your ~/.bash_aliases file to ease the usage of the `microk8s kubectl` client.

The following aliases are created:
| Alias	| Command | Notes |
|---	|---	|---	|
| m8s | `microk8s` | For commands, e.g. `m8s start/stop` |
| mk | `microk8s kubectl` | To query the k8s API, e.g. `m8sk get services` |
| mkgp | `microk8s kubectl get pods` | To query the k8s API for pods in the current namespace |
| mksys | `microk8s kubectl config set-context --current --namespace kube-system` | For easier troubleshooting of system components located in the kube-system namespace |

## Known Issues
After the installation is done, the calico-node pods in the kube-system namespace can fail to discover the ip-range to create their vxlan adapters in.

Because I am using this installation on my laptop where the calico-node pods always fail, the default configuration for the `microk8s` role applies a fix for it by default. If you don't have this problem or if the mechanism is not working for you, set `vxlan.fix` to `false` in the [defaults/main.yaml file](ansible/roles/microk8s/defaults/main.yaml).

For more information about this problem, checkout:
* https://github.com/projectcalico/calico/issues/3094
* https://docs.projectcalico.org/reference/node/configuration#ip-autodetection-methods

# Uninstall
To uninstall microk8s, remove your user from the microk8s group and delete the microk8s group, run

```bash
scripts/uninstall.sh
```

from the root of this repository.