# microk8s
This repo can be used to setup a local k8s environment for development and test purposes based on microk8s. Checkout https://microk8s.io/ for more information.

## Install
Run the following commands to start the installation:
  * <code>cd ansible && ./venv-setup.sh && source .venv/bin/activate</code>
  * Start the installation with <code>ansible-playbook playbook.yaml</code> and provide your sudo password when prompted
  * After the installation has finished, refresh your shell with <code>su $(whoami)</code>
  * List all running pods by <code>mkctl get pods --all-namespaces</code>

After the microk8s installation is done, the kubernetes-dashboard UI will be available at <code>http://localhost:30001</code>.

### Bash aliases
The playbook appends aliases to your ~/.bash_aliases file to ease the usage of the `microk8s kubectl` client. The following aliases are created:

| Alias	| Command                     | Notes                                                  |
|-------|-----------------------------|--------------------------------------------------------|
| m8s   | `microk8s`                  | For commands, e.g. `m8s start`                         |
| mkctl | `microk8s kubectl`          | To query the k8s API, e.g. `mkctl get services`        |


## Deinstall
To deinstall the microk8s environment, run
* <code>cd ansible && ./venv-setup.sh && source .venv/bin/activate</code>
* <code>ansible-playbook deinstall.yaml</code> and provide your sudo password when prompted
