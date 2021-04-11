# TL;DR
```bash
ansible-galaxy collection install -r requirements.yaml
```

```bash
ansible-playbook install-microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>"
```

```bash
su - $(whoami)
```

```bash
ansible-playbook setup-microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>"
```

# TOC
- [TL;DR](#tldr)
- [TOC](#toc)
- [Goal of this Repo](#goal-of-this-repo)
  - [Usage](#usage)
    - [Aliases](#aliases)
    - [Debugging](#debugging)
    - [Known Issues](#known-issues)
    - [Extended Usage](#extended-usage)
  - [Enabled add-ons](#enabled-add-ons)
  - [Additional configuration](#additional-configuration)
  - [Ingress Hosts](#ingress-hosts)
    - [Additional Ingress Hosts](#additional-ingress-hosts)
  - [Uninstall](#uninstall)

# Goal of this Repo
This repo is meant to be used for the installation and setup of a local one-node kubernetes environment for development and test purposes.

The installation and setup is done via ansible to ensure a deterministic state on multiple install and setup runs. It uses Microk8s (v1.19) and its add-ons to bootstrap a local kubernetes environment in an opinionated way. Check out [Microk8s](https://microk8s.io) to learn more about the idea behind it and its features.

**Disclaimer:** The files in this repo are work-in-progress and not tested on anything but my local setup with Ubuntu 20.10 (Groovy Gorilla).

## Usage
The playbook depends on ansible-galaxy collections to create a local pki via openssl, deploy kubernetes manifests and helm charts. 

To install the ansible-galaxy collections on your machine, run:

```bash
ansible-galaxy collection install -r requirements.yaml
```

To install microk8s and start, run:
```bash
ansible-playbook install-microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>"
```
and:

```bash
su - $(whoami)
```

After the installation is done and you logged in again, query the Microk8s API via:

```bash
m8sk get pods --all-namespaces
```

To setup the microk8s plugins, pki, certificates, routes and monitoring, run:
```bash
ansible-playbook setup-microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>"
```

### Aliases
The Playbook appends aliases to your $HOME/.bash_aliases file to ease the usage of the `microk8s kubectl` client used to interact with the Kubernetes API.

The following aliases are created:
```
m8s=microk8s (for commands like "m8s start/stop")

m8sk=microk8s kubectl (for commands like "m8sk get pods")

m8sksys=microk8s kubectl config set-context --current --namespace kube-system (for easier troubleshooting of system components in kube-system namespace)
```

### Debugging
If you want to see more details about what the playbook does, run
```bash
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>" \
  -vv
```
to enable a more verbose output for the playbook run.

### Known Issues
After finishing the installation, the calico-node pods in the kube-system namespace can be stuck in a CrashLoopBackOff failing to autodiscover the ip-range to create their vxlan adapters in. You can fix the autodiscover method manually after installing Microk8s with the `install-microk8s.yaml` playbook:

1. Check your available network interfaces:
```bash
ip a
```

2. Set the network interface to use for the calico-node DaemonSet: 
```bash
m8sk set env ds/calico-node IP_AUTODETECTION_METHOD="interface=<interfaceName>" --namespace kube-system
```

3. Restart all pods in the kube-system namespace:
```bash
m8sk delete pods --all --namespace kube-system
```

For more information, checkout:
* https://github.com/projectcalico/calico/issues/3094
* https://docs.projectcalico.org/reference/node/configuration#ip-autodetection-methods

### Extended Usage
If you do not use Ubuntu, but want to use the playbook to configure your Microk8s setup, install Microk8s on your machine and use the individual roles/tasks separately:

```bash
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>" \
  --tags "cert-manager"
```

**Note**: Some tasks cannot be run individually, because they rely on  outputs from other tasks. This will be fixed in the future.

## Enabled add-ons
Microk8s comes with add-ons that can be enabled to bootstrap preconfigured deployments for components like logging, monitoring or a container-registry. The following add-ons will be enabled by the `setup-microk8s.yaml` playbook:

* ingress
* rbac
* registry
* fluentd
* prometheus

**Note:** The dashboard add-on is not enabled on purpose, because its default configuration is not compatible with the ingress setup done by the `setup-microk8s.yaml` playbook. The kubernetes-dashboard will be deployed without enabling the add-on and is accessible at `https://dashboard.micr0k8s.local` after the setup is done.

## Additional configuration
In addition to enabling the listed Microk8s add-ons the playbook will edit, generate and deploy some files to ensure a comprehensive experience with the local kubernetes environment:

* add the current user to the microk8s group to interact with Microk8s as a non-root user
* append aliases for common commands to the $HOME/.bash_aliases file
* generate a $HOME/.kube/microk8s_config file to interact with the Kubernetes API
* create a local openssl pki
  * update local ca-store
  * update mozilla firefoxes ca-store
  * deploy a cert-manager setup to levearge a cluster-internal pki
  * add entries to the /etc/hosts file for `*.microk8s.local` ingress hosts
  * deploy ingress manifests for the installed services and add-ons
* deploy the kubernetes-dashboard
* setup prometheus monitoring for cert-manager and elasticsearch with grafana dashboards and metrics exporters

## Ingress Hosts
After the installation and setup is done, the following services are available:
* kubernetes-dashboard: https://dashboard.microk8s.local
* kibana: https://kibana.microk8s.local
* prometheus: https://prometheus.microk8s.local
* alertmanager: https://alertmanager.microk8s.local
* grafana: https://grafana.microk8s.local (login via default credentials admin:admin)

### Additional Ingress Hosts
The pki certificate will be generated for `*.microk8s.local` domains, so it can be used for any additional services you want to deploy into your Microk8s setup. 

Make sure your ingress manifests use the cert-manager annotation to automatically create a valid tls-secret for your domain. Check out the [files/ing-*.yaml](roles/setup/files) manifests and check out [cert-manager docs](https://cert-manager.io/docs/usage/ingress/) for more details.

Also, don't forget to add your ingress-host to your local `/etc/hosts` file.

## Uninstall
To uninstall microk8s, remove your user from the microk8s group and delete the microk8s group, execute

```bash
./uninstall.sh
```

from the root of this repository.