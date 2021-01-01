# Goals for this Repo
This repo is meant to be used for the installation and setup of a local kubernetes environment for development and test purposes.

The installation and setup is done via ansible to ensure a deterministic state on multiple install and setup runs. It uses Microk8s and its add-ons to bootstrap a local kubernetes environment in an opinionated way. Check out [Microk8s](https://microk8s.io) to learn more about the idea behind it and its features.

**Disclaimer**: The files in this repo are work-in-progress and not tested on anything other than my local setup (Ubuntu 20.10). If you do not use Ubuntu but want to use the playbook from this repo, install Microk8s on your machine and use the specific roles and tasks separately:
```yaml
ansible-playbook microk8s.yaml \
  --extra-vars ansible_sudo_pass="<your sudo password>" \
  --tags "jenkins" \
  --start-at-task "deploy helm chart"
```

## Enabled add-ons
Microk8s comes with add-ons that can be enabled to bootstrap a preconfigured deployment of the add-ons components. The following add-ons will be enabled:

* rbac
* dns
* helm3
* ingress
* storage
* fluentd
* prometheus
* registry

Note: The dashboard add-on is not enabled on purpose, because the configration of the add-on is not compatible with a senseable ingress-setup if you want to communicate via tls with the service. The kubernetes-dashboard will be deployed seperately to ensure proper tls communication via ingress-route and less frequent login requests.

## Additional configuration
In addition to enabling the listed Microk8s add-ons, the ansible roles will edit, generate and deploy some files to ensure a comprehensive experience with the local kubernetes-cluster:

* add the current user to the microk8s group to interact with Microk8s as a non-root user
* append aliases for common commands like `microk8s kubectl` to the ~/.bash_aliases file
* generate a ~/.kube/config file for the current user to be able to login and use the kubernetes-dashboard as cluster-admin
* create a local openssl pki and update ubuntus and mozilla firefoxes ca-store to ensure successful tls communication with mozilla firefox and cli programs like curl
* deployment of a cert-manager setup to levearge a cluster-internal pki to secure in-cluster communication (for self-developed services) and ingress-routes via tls
* add entries to the /etc/hosts file to make exposed ingress-routes accessible via *.microk8s.local urls
* deployment of ingress resources to make all services available via a *.microk8s.local domain
* deployment of the kubernetes-dashboard with proper tls termination and altered settings for less frequent login requests
* deployment of a jenkins-server with a senseable baseline configuration of plugins to use it with kubernetes
* deployment of podmonitors and grafana dashboards to ensure a comprehensive monitoring experience for the installed services via prometheus-stack