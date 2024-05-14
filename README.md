# Microk8s
This repo can be used to setup a local kubernetes installation based on microk8s.
Checkout https://microk8s.io/ for more.

## Prerequisites
For general prerequisites of microk8s, see https://microk8s.io/docs/getting-started.

Run these commands to install the necessities for the automation:

```
sudo apt install python3-pip -y && \
sudo snap install helm --classic && \
helm plugin install https://github.com/databus23/helm-diff --version v3.9.6 && \
python3 -m pip install --upgrade --user -r requirements.txt && \
ansible-galaxy collection install -r requirements.yaml
```

## Install
Run the following commands to start the installation:
  * Start with <code>ansible-playbook install.yaml</code>
  * Refresh your shell with <code>su - $(whoami)</code>
  * Ensure the client works with <code>mkctl get pods --all-namespaces</code>

**Note:** If passwordless sudo is disabled on your machine, force ansible to ask for the sudo password by appending <code>--ask-become-pass</code> to the <code>ansible-playbook install.yaml</code> command. 

The kubernetes-dashboard UI will be available at <code>http://localhost:30001</code>.
You can retrieve a login token with <code>microk8s kubectl get secret kubernetes-dashboard-admin-token -n kubernetes-dashboard -o jsonpath={'.data.token'} | base64 -d | awk '{print $1}'</code>.

### Interact with microk8s
After the installation, microk8s will be running but it won't be added to the autostart.

To start microk8s, run `microk8s start && microk8s status --wait-ready`. It can take some time
for all services to be ready/running and available via nodeports, ingresses etc. even after 
the command returns.

To stop microk8s, run `microk8s stop`.

See `microk8s help` for a list of all available subcommands.

### Aliases
The playbook creates aliases to ease the usage of `microk8s` and `microk8s kubectl` commands.
It also exports the `KUBECONFIG` env so you can work with other clients like oc/kubectl/helm etc.
as with any other kubernetes installation.

The following aliases are created:

| Alias | Command                                                         | Notes                                                                                |
| ----- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| mk8s  | `microk8s`                                                      | For commands controlling microk8s itself, e.g. `mk8s start` or `mk8s stop`           |
| mkctl | `microk8s kubectl`                                              | To run kubectl commands with the included binary, e.g. `mkctl get services`          |
| mkns  | `microk8s kubectl config set-context microk8s --namespace <ns>` | To set a namespace for subsequent microk8s kubectl commands, e.g. `mkns kube-system` |

## Deinstall
To deinstall the microk8s, run <code>ansible-playbook deinstall.yaml</code>.
If passwordless sudo is disabled, run <code>ansible-playbook deinstall.yaml --ask-become-pass</code> instead.
