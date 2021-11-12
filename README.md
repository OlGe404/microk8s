# TL;DR
```bash
scripts/install-packages.sh && \
ansible-playbook playbook.yaml
```

# TOC
- [TL;DR](#tldr)
- [TOC](#toc)
- [Purpose](#purpose)
- [Usage](#usage)
  - [WebUI](#webui)
    - [Bash aliases](#bash-aliases)
  - [Known Issues](#known-issues)
- [Uninstall](#uninstall)

# Purpose
This repo is meant to be used for the installation and setup of a local k8s environment for development and test purposes.

The installation and setup is done with ansible to ensure a deterministic state on multiple installs. The playbook will edit, generate and deploy some files to ensure a comprehensive experience with the local k8s environment:

* add the current user to the microk8s group to interact with Microk8s as a non-root user
* append aliases for common commands to the ~/.bash_aliases file
* generate a ~/.kube/microk8s_config file to interact with the k8s API
* deploy the k8s-dashboard as a WebUI for the k8s environment

The default configuration will install Microk8s in its `latest/stable` version with the `rbac`, `dns`, `storage` and `ingress` add-ons enabled. Check out [Microk8s](https://microk8s.io) to learn more about the idea behind it and the available features.

**Hint:** If you want to install a specific version of Microk8s or install additional add-ons by default, you can overwrite the default parameters via CLI when calling the playbook or by altering the `defaults/main.yaml` file for the `install` and `add-ons` role.

**Disclaimer:** The files in this repo are work-in-progress and not tested on anything but my laptop with Ubuntu 20.04.2 LTS (Focal Fossa). It should be fine to run on other devices too, but if you encounter any problems check the [Known Issues](#known-issues) section.

# Usage
To install the necessary tools and packages, run:

```bash
scripts/install-packages.sh
```

To setup the local k8s environment, run
```bash
ansible-playbook playbook.yaml
```

When the installation is done, you can query the Microk8s API via

```bash
mk get pods --all-namespaces
```

**Hint:** You may need to (re)login to the shell or atleast refresh the groups for your user to interact with the k8s API. Run `su $(whoami)` or `newgrp microk8s` to do so.

## WebUI
After the installation is done and the `k8s-dashboard` role was executed successfully, the WebUI will be available at `http://localhost:30001` in your Webbrowser.

### Bash aliases
The playbook appends aliases to your ~/.bash_aliases file to ease the usage of the `microk8s kubectl` client.

The following aliases are created:
| Alias	| Command | Notes |
|---	|---	|---	|
| m8s | `microk8s` | For commands, e.g. `m8s start/stop` |
| mk | `microk8s kubectl` | To query the k8s API, e.g. `m8sk get pods` |
| mksys | `microk8s kubectl config set-context --current --namespace kube-system` | For easier troubleshooting of system components located in the kube-system namespace |

## Known Issues
After the installation is done, the calico-node pods in the kube-system namespace can be stuck in a CrashLoopBackOff failing to autodiscover the ip-range to create their vxlan adapters in.

Because I am using this installation mostly on my laptop where the calico-node pods always fail to autodiscover the correct network adapters, the default configuration for the `install` role applies a fix for it by default. If you don't have this problem or if the mechanism is not working for you, set `vxlan.fix` value to `false` in the `defaults/main.yaml` for the `install` role.


For more information about this problem, checkout:
* https://github.com/projectcalico/calico/issues/3094
* https://docs.projectcalico.org/reference/node/configuration#ip-autodetection-methods

# Uninstall
To uninstall microk8s, remove your user from the microk8s group and delete the microk8s group, run

```bash
./uninstall.sh
```

from the root of this repository.