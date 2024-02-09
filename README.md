```bash
/bin/bash
# set up necessary environment variables
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES # Ansible bug workaround
set +o history
export PKR_VAR_vm_password='RealPasswordHere'
set -o history

# Build the template
packer init src/base.pkr.hcl
packer build src/base.pkr.hcl

# Add the tools
packer init src/install-tools.pkr.hcl
packer build src/install-tools.pkr.hcl
```

## To drop into a terminal during boot
Ctrl + Alt + F2

## Testing the ansible playbook

```bash
ansible-playbook --ssh-extra-args '-o StrictHostKeyChecking=no' -i TARGET_IP_ADDRESS, -u SSH_USER --extra-vars 'ansible_ssh_pass=SSH_PASS' --extra-vars '{vm_tools_dir: /opt/, vm_username: SSH_USER, vm_hostname: mesa-ops}' ansible/playbook.yml
```
