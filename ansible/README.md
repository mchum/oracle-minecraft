# Ansible
Using for configuring nodes to
* Join to private network (tailscale + traefik)
* Install K3s
* Configure K3s agent to join to the cluster

## Run playbook
```
ansible-playbook --vault-password-file ~/.secrets/ansible_vault_password_file -i ./hosts.ini site.yaml
```