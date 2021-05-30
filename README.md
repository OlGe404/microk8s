# TL;DR
```bash
ansible-playbook install-microk8s.yaml
```

# TOC
- [TL;DR](#tldr)
- [TOC](#toc)
- [Purpose](#purpose)
  - [Usage](#usage)
    - [WebUI](#webui)
    - [Aliases](#aliases)
    - [Known Issues](#known-issues)
  - [Additional configuration](#additional-configuration)
  - [Uninstall](#uninstall)

# Purpose
This repo is meant to be used for the installation and setup of a local one-node kubernetes environment for development and test purposes.

The installation and setup is done with ansible to ensure a deterministic state on multiple installs. The playbook will edit, generate and deploy some files to ensure a comprehensive experience with the local kubernetes environment:

* add the current user to the microk8s group to interact with Microk8s as a non-root user
* append aliases for common commands to the $HOME/.bash_aliases file
* generate a $HOME/.kube/microk8s_config file to interact with the Kubernetes API
* deploy the kubernetes-dashboard

The default configuration will install Microk8s in its `latest/stable` version with the `rbacs` and `dns` add-ons enabled. Check out [Microk8s](https://microk8s.io) to learn more about the idea behind it and the available features.

**Hint:** If you want to install a specific version of Microk8s and install additional add-ons by default, you can overwrite the default parameters via CLI when calling the playbook or by altering the `defaults/main.yaml` file for the `install` and `add-ons` role.

**Disclaimer:** The files in this repo are work-in-progress and not tested on anything but my laptop with Ubuntu 20.04.2 LTS (Focal Fossa). It should be fine to run on other devices too, but if you encounter any problems check the [Known Issues](#known-issues).

## Usage
The playbook depends on a ansible-galaxy collection to deploy kubernetes manifests for the k8s-Dashboard as a WebUI. 

To install the ansible-galaxy collection on your machine, run:

```bash
ansible-galaxy collection install -r requirements.yaml
```

To install microk8s, run:
```bash
ansible-playbook install-microk8s.yaml
```

When the installation is done, reboot your machine. Afterwards you can query the Microk8s API via:

```bash
m8sk get pods --all-namespaces
```

### WebUI
After the installation is done and the `k8s-dashboard` role was executed successfully, a WebUI will be available at `http://localhost:30001` in your Webbrowser.

### Aliases
The Playbook appends aliases to your $HOME/.bash_aliases file to ease the usage of the `microk8s kubectl` client used to interact with the Kubernetes API.

The following aliases are created:
| Alias	| Command | Notes |
|---	|---	|---	|
| m8s | microk8s | For commands, e.g. `m8s start/stop` |
| m8sk | microk8s kubectl | To query the k8s API, e.g. `m8sk get pods` |
| m8sksys | microk8s kubectl config set-context --current --namespace kube-system | For easier troubleshooting of system components located in the kube-system namespace |

### Known Issues
After the installation is done, the calico-node pods in the kube-system namespace can be stuck in a CrashLoopBackOff failing to autodiscover the ip-range to create their vxlan adapters in. In my experience, this can happen if you have a wifi module installed in your device (e.g. on a Laptop).

Because I am using this installation mostly on my laptop where the calico-node pods always fail to autodiscover the correct network adapters, the default configuration for the `install` role always tries to fix it automatically. If you do **not** have problems with your calico-node pods or if the default mechanism is not working for you, alter the default variables for the `install` role and set `vxlan.fix` values to `false`.


For more information about this problem, checkout:
* https://github.com/projectcalico/calico/issues/3094
* https://docs.projectcalico.org/reference/node/configuration#ip-autodetection-methods

## Uninstall
To uninstall microk8s, remove your user from the microk8s group and delete the microk8s group, execute

```bash
./uninstall.sh
```

from the root of this repository.