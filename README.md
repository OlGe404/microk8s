# TL;DR
```bash
ansible-galaxy collection install -r requirements.yaml
```

```bash
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>"
```

# TOC
* [Goal of this Repo](#Goals-of-this-Repo)
* [Usage](#Usage)
  * [Debugging](#Debugging)
  * [Extended Usage](#Extended-Usage)
* [Enabled add-ons](#Enabled-add-ons)
* [Additional configuration](#Additional-configuration)
* [Ingress Hosts](#Ingress-Hosts)
  * [Additional Ingress Hosts](#Additional-Ingress-Hosts)

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

To use the playbook afterwards, run: 
```bash
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>"
```

### Debugging
If you want to see more details about what the playbook does, run
```bash
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>" \
  -vv
```
to enable a more verbose output for the playbook run.

### Extended Usage
If you do not use Ubuntu, but want to use the playbook to configure your Microk8s setup, install Microk8s on your machine and use the individual roles/tasks separately:

```bash
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>" \
  --tags "jenkins" \
  --start-at-task "add codecentric helm repo"
```

**Note:** When you want to deploy jenkins without running the setup role prior to it, you have to make sure helm is already installed on your machine and in the $PATH for your user.

## Enabled add-ons
Microk8s comes with add-ons that can be enabled to bootstrap a preconfigured deployment for the add-on components. The following add-ons will be enabled:

* rbac
* dns
* helm3
* ingress
* storage
* fluentd
* prometheus
* registry

**Note:** The dashboard add-on is not enabled on purpose, because its default configuration is not compatible with the ingress setup done by this playbook. The kubernetes-dashboard will be deployed seperately and accessible via the [ingress host](#Ingress-Hosts), so you don't have to use `kubectl proxy` or `kubectl port-forward` to access the UI in your browser.  

## Additional configuration
In addition to enabling the listed Microk8s add-ons the playbook will edit, generate and deploy some files to ensure a comprehensive experience with the local kubernetes-cluster:

* add the current user to the microk8s group to interact with Microk8s as a non-root user
* append aliases for common commands to the $HOME/.bash_aliases file
* generate a $HOME/.kube/microk8s_config file to login and use the kubernetes-dashboard as cluster-admin
* create a local openssl pki
  * update ubuntus ca-store
  * update mozilla firefoxes ca-store
  * deploy a cert-manager setup to levearge a cluster-internal pki
  * add entries to the /etc/hosts file for `*.microk8s.local` ingress hosts
  * deploy ingress manifests for the installed services
* deploy the kubernetes-dashboard with altered settings for less frequent login requests and tls via ingress
* deploy a jenkins-server with a baseline configuration of plugins to use within kubernetes
* deploy podmonitors and grafana dashboards for a comprehensive monitoring experience via prometheus-stack

## Ingress Hosts
After the installation and setup is done, the following services are available:
* kubernetes-dashboard: https://dashboard.microk8s.local (login via $HOME/.kube/microk8s_config file)
* kibana: https://kibana.microk8s.local
* prometheus: https://prometheus.microk8s.local
* alertmanager: https://alertmanager.microk8s.local
* grafana: https://grafana.microk8s.local (login via default credentials admin:admin)
* jenkins https://jenkins.microk8s.local (checkout the [codecentric helm-repo](https://github.com/codecentric/helm-charts/tree/master/charts/jenkins) for more information)

### Additional Ingress Hosts
The certificate for the tls communication will be generated for `*.microk8s.local` domains from the cert-manager setup, so it can be used for any additional services you want to deploy into your Microk8s setup. 

Make sure your ingress manifests use the cert-manager annotation to automatically create a valid tls-secret for your domain. Check out the [files/ing-*.yaml](roles/setup/files) manifests from the setup role or see the [cert-manager docs](https://cert-manager.io/docs/usage/ingress/) for more details.