# TL;DR
```bash
ansible-galaxy collection install -r requirements.yaml
```

```bash
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>"
```

# TOC
* [Goals for this Repo](#Goals-for-this-Repo)
* [Enabled add-ons](#Enabled-add-ons)
* [Additional configuration](#Additional-configuration)
* [Ingress Hosts](#Ingress-Hosts)
  * [Additional Ingress Hosts](#Additional-Ingress-Hosts)

# Goals for this Repo
This repo is meant to be used for the installation and setup of a local kubernetes environment for development and test purposes.

The installation and setup is done via ansible to ensure a deterministic state on multiple install and setup runs. It uses Microk8s and its add-ons to bootstrap a local kubernetes environment in an opinionated way. Check out [Microk8s](https://microk8s.io) to learn more about the idea behind it and its features.

**Disclaimer:** The files in this repo are work-in-progress and not tested on anything other than my local one-node setup (Ubuntu 20.10). If you do not use Ubuntu but want to use the playbook from this repo to configure your Microk8s setup, install Microk8s on your machine and use the specific roles and tasks separately:
```yaml
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>" \
  --tags "jenkins" \
  --start-at-task "deploy helm chart"
```

## Enabled add-ons
Microk8s comes with add-ons that can be enabled to bootstrap a preconfigured deployment of the add-on components. The following add-ons will be enabled:

* rbac
* dns
* helm3
* ingress
* storage
* fluentd
* prometheus
* registry

**Note:** The dashboard add-on is not enabled on purpose, because the default configuration of the add-on is not compatible with a senseable ingress-setup if you want to communicate via tls with the service. The kubernetes-dashboard will be deployed seperately to ensure tls communication via the ingress-route and less frequent login requests (and you dont have to use `kubectl proxy` or `kubectl port-forward` to access the UI in your browser).  

## Additional configuration
In addition to enabling the listed Microk8s add-ons, the ansible roles will edit, generate and deploy some files to ensure a comprehensive experience with the local kubernetes-cluster:

* add the current user to the microk8s group to interact with Microk8s as a non-root user
* append aliases for common commands like `microk8s kubectl` to the ~/.bash_aliases file
* generate a ~/.kube/microk8s_config file for the current user to be able to login and use the kubernetes-dashboard as cluster-admin
* create a local openssl pki and update ubuntus and mozilla firefoxes ca-store to ensure successful tls communication with mozilla firefox and cli programs like curl
* deployment of a cert-manager setup to levearge a cluster-internal pki to secure in-cluster communication (for self-developed services) and ingress-hosts via tls
* add entries to the /etc/hosts file to make ingress-hosts accessible via *.microk8s.local urls
* deployment of ingress resources to make all installed services available via a *.microk8s.local domain
* deployment of the kubernetes-dashboard with tls termination and altered settings for less frequent login requests
* deployment of a jenkins-server with a senseable baseline configuration of plugins to use within kubernetes
* deployment of podmonitors and grafana dashboards to ensure a comprehensive monitoring experience for the installed services via prometheus-stack

## Ingress Hosts
After the installation and setup is done, the following services are available:
* kubernetes-dashboard: https://dashboard.microk8s.local (with the generated ~/.kube/microk8s_config file)
* kibana: https://kibana.microk8s.local
* prometheus: https://prometheus.microk8s.local
* alertmanager: https://alertmanager.microk8s.local
* grafana: https://grafana.microk8s.local (with the default credentials admin:admin)
* jenkins https://jenkins.microk8s.local

### Additional Ingress Hosts
The certificate used to encrypt the tls communication for the ingress hosts is dynamically generated for the `*.microk8s.local` domains, so it can be used for any additional services you want to deploy into your Microk8s setup. Make sure your ingress-resources use the cert-manager annotation to dynamically create a valid tls-secret for your domain. Check out the `ing-*.yaml` files from the setup role to use them as a template and the [cert-manager docs](https://cert-manager.io/docs/usage/ingress/) for more details.