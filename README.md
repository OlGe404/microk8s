# microk8s
This repo can be used to setup a local k8s environment for development and test purposes based on microk8s.

## Install
Run the following commands to start the installation:
  * <code>cd ansible && ./venv-setup.sh && source .venv/bin/activate</code>
  * Start the installation with <code>ansible-playbook playbook.yaml</code> and provide your sudo password when prompted
  * After the installation has finished, refresh your shell with <code>su $(whoami)</code>
  * List all running pods by <code>mkgp --all-namespaces</code>

After the microk8s installation is done, the kubernetes-dashboard UI will be available at <code>http://localhost:30001</code>.

### Bash aliases
The playbook appends aliases to your ~/.bash_aliases file to ease the usage of the `microk8s kubectl` client. The following aliases are created:

| Alias	| Command                     | Notes                                                  |
|-------|-----------------------------|--------------------------------------------------------|
| m8s   | `microk8s`                  | For commands, e.g. `m8s start`                         |
| mk    | `microk8s kubectl`          | To query the k8s API, e.g. `mk get services`           |
| mkgp  | `microk8s kubectl get pods` | To query the k8s API for pods in the current namespace |


## Deinstall
To deinstall the microk8s environment, run
* <code>cd ansible && ./venv-setup.sh && source .venv/bin/activate</code>
* <code>ansible-playbook deinstall.yaml</code> and provide your sudo password when prompted
