# Microk8s
This repo can be used to setup a local kubernetes installation based on microk8s.
Checkout https://microk8s.io/ for more.

## Prerequisites
For general prerequisites of microk8s, see https://microk8s.io/docs/getting-started.

Run <code>./prerequisites.sh</code> to install the prerequisites for this repo.

## Install
Install microk8s with the following commands:
  * <code>ansible-playbook install.yaml</code>
  * Refresh your shell with <code>su - $(whoami)</code>
  * Ensure the client and aliases work with <code>mkctl get pods --all-namespaces</code>

**Note:** If passwordless sudo is disabled on your machine, force ansible to ask for the sudo password by appending <code>-K</code> or <code>--ask-become-pass</code> to the <code>ansible-playbook install.yaml</code> command.

### Dashboard
The kubernetes-dashboard will be installed in microk8s using the [official helm chart](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard).
We don't use the microk8s dashboard add-on to be able to customize the installation and access the dashboard without using a port-forward/proxy command. The dashboard will be available at <code>http://localhost:30001</code> after the microk8s installation and dashboard rollout has finished.

You can retrieve the login token for the dashboard with <code>microk8s kubectl get secret kubernetes-dashboard-admin-token -n kubernetes-dashboard -o jsonpath={'.data.token'} | base64 -d | awk '{print $1}'</code>.

### Work with microk8s
After the installation is done, microk8s will be up and running but it won't be added to your systems autostart. To start microk8s, run `microk8s start && microk8s status --wait-ready`. It can take some time for all services that are deployed in microk8s to be up and running, even after the command returns.

To stop microk8s, run `microk8s stop`. See `microk8s help` for a list of all available subcommands.

The kubeconfig file to interact with microk8s will be created at <code>~/.kube/microk8s</code> and an alias will be created automatically to set <code>export KUBECONFIG=~/.kube/microk8s</code> on login. If you don't want to use that, set <code>microk8s_manage_kubeconfig=false</code>.

Microk8s is bundled with the kubectl cli. If you don't have kubectl installed, or you only want to use it in the microk8s context, set <code>microk8s_manage_kubectl=true</code> to let the installation create a <code>kubectl='microk8s kubectl'</code> alias for you.

### Aliases
The playbook creates aliases to ease the usage of `microk8s` and `microk8s kubectl` commands.
It also exports the `KUBECONFIG` ENV so you can work with other clients like oc/kubectl/helm as usual.

The following aliases are created:

| Alias | Command                                                         | Notes                                                                                |
| ----- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| mk8s  | `microk8s`                                                      | For commands controlling microk8s itself, e.g. `mk8s start` or `mk8s stop`           |
| mkctl | `microk8s kubectl`                                              | To run kubectl commands with the included binary, e.g. `mkctl get services`          |
| mkns  | `microk8s kubectl config set-context microk8s --namespace <ns>` | To set a namespace for subsequent microk8s kubectl commands, e.g. `mkns kube-system` |
| mktoken | 'microk8s kubectl get secret kubernetes-dashboard-admin-token -n kubernetes-dashboard -o jsonpath={'.data.token'} | base64 -d | awk '{print $1}'' | Get the login token for the kubernetes-dashboard |

## Deinstall
To deinstall microk8s, run <code>ansible-playbook deinstall.yaml</code>.
If passwordless sudo is disabled, run <code>ansible-playbook deinstall.yaml -K</code> instead.
