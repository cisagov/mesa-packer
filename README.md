# MESA Packer

A HashiCorp Packer project for building automated MESA (Micro Evaluation Security Assessment) virtual machines with pre-installed security assessment tools.

## Overview

This project creates a Debian-based virtual machine optimized for cybersecurity assessment tasks. It uses Packer to automate the VM creation process and Ansible to provision security tools and configurations.

## Features

- **Automated VM Creation**: Uses Packer to build VMware-compatible virtual machines
- **Security Tools Integration**: Installs MESA toolkit and GUI interface
- **Web Interface**: Django-based web GUI with SSL support
- **Service Management**: Systemd services for MESA components
- **XFCE Desktop Environment**: Lightweight desktop environment for GUI tools

## Prerequisites

### Development Environment
- **Operating System**: macOS Sonoma (tested environment)
- **Hardware**: MacBook Pro (recommended)

### Required Software
Install the following tools using Homebrew:

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install packer
brew install ansible
brew install --cask vmware-fusion  # or VMware Workstation Pro
```

### VMware Requirements
- VMware Fusion (macOS) or VMware Workstation Pro
- VMware Workstation Pro is now free for personal use (no license required)
- Sufficient disk space (minimum 80GB for VM)
- Minimum 8GB RAM allocated to VM

## Project Structure

```
mesa-packer/
├── README.md                   # This file
├── src/                        # Packer source files
│   ├── base.pkr.hcl           # Base VM configuration
│   ├── install-tools.pkr.hcl  # Tools installation configuration
│   └── http/                   # Boot configuration files
│       └── preseed.pkrtpl.hcl # Debian preseed template
└── ansible/                   # Ansible provisioning
    ├── playbook.yml           # Main playbook
    ├── mesa-toolkit.yml       # MESA tools installation
    ├── apt.yml                # APT package management
    ├── assessment_tools.yml   # Additional security tools
    ├── git-clone.yml          # Git repository cloning
    ├── mesa.service.j2        # Systemd service template
    └── templates/             # Configuration templates
        └── nginx.conf.j2      # Nginx configuration
```

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/cisagov/mesa-packer.git
cd mesa-packer
```

### 2. Configure Environment
```bash
# Set up necessary environment variables
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES  # Ansible bug workaround for macOS
set +o history  # Temporarily disable command history
export PKR_VAR_vm_password='YourSecurePasswordHere'  # Set VM password
export PKR_VAR_mesa_user_password='YourMesaUserPassword'  # Set MESA application user password
export PKR_VAR_mesa_user_name='mesa_admin'  # Set MESA application username (optional)
set -o history  # Re-enable command history
```

### 3. Build Base VM
```bash
# Initialize Packer plugins
packer init src/base.pkr.hcl

# Build the base VM template
packer build src/base.pkr.hcl
```

### 4. Install MESA Tools
```bash
# Initialize tools installation
packer init src/install-tools.pkr.hcl

# Build VM with MESA tools
packer build src/install-tools.pkr.hcl
```

## Configuration

### VM Configuration Variables

The following variables can be customized in your Packer build:

| Variable | Default | Description |
|----------|---------|-------------|
| `vm_username` | `mesa` | VM user account name |
| `vm_password` | `mesa` | VM user password (set via PKR_VAR_vm_password) |
| `vm_hostname` | `base-deb` | VM hostname |
| `vm_domain` | `mesa.local` | VM domain name |
| `vm_user_fullname` | `Mesa User` | Full name for VM user |
| `mesa_user_name` | `mesa` | MESA application username |
| `mesa_user_password` | `mesa` | MESA application password (set via PKR_VAR_mesa_user_password) |
| `output_directory` | `~/Virtual Machines.localized/base-deb` | VM output location |

### Example Custom Build
```bash
export PKR_VAR_vm_username='analyst'
export PKR_VAR_vm_hostname='mesa-workstation'
export PKR_VAR_vm_password='SecurePassword123!'
export PKR_VAR_mesa_user_name='security_admin'
export PKR_VAR_mesa_user_password='MesaAppPassword456!'
packer build src/base.pkr.hcl
```

## Troubleshooting

### Common Issues

#### Installation Fails at "Select and install software"
This typically indicates preseed configuration issues:
- Check network connectivity during build
- Verify Debian mirror accessibility
- Ensure preseed file syntax is correct

#### VMware Plugin Issues
```bash
# Reinstall VMware plugin
packer plugins install github.com/hashicorp/vmware
```

#### Ansible Connection Issues
```bash
# Test Ansible connectivity
ansible all -i <VM_IP>, -u mesa -m ping --ask-pass
```

#### Boot Command Issues
- Increase `boot_wait` time if VM boots too slowly
- Verify VMware hardware acceleration settings
- Check VM memory allocation (minimum 8GB recommended)

### Debug Mode
Run Packer with debug flags for detailed output:
```bash
PACKER_LOG=1 packer build src/base.pkr.hcl
```

### Accessing VM During Boot
To access a terminal during installation:
- Press `Ctrl + Alt + F2` to switch to console
- Press `Ctrl + Alt + F1` to return to installer

## Manual Testing

### Testing Ansible Playbook Directly
```bash
ansible-playbook \
  --ssh-extra-args '-o StrictHostKeyChecking=no' \
  -i <TARGET_IP_ADDRESS>, \
  -u <SSH_USER> \
  --extra-vars 'ansible_ssh_pass=<SSH_PASS>' \
  --extra-vars '{
    vm_tools_dir: /opt/, 
    vm_username: <SSH_USER>, 
    vm_hostname: mesa-ops,
    mesa_user_password: <PASSWORD>,
    mesa_user_name: <USERNAME>
  }' \
  ansible/playbook.yml
```

## Development

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Standards
- Follow HashiCorp HCL style guidelines
- Use descriptive variable names
- Comment complex configurations
- Test changes on clean VMs

## Security Considerations

- Change default passwords before deployment
- Review firewall configurations
- Validate SSL certificate settings
- Audit installed packages regularly
- Keep base OS and tools updated

## License

This project is released under the terms specified by CISA/DHS. See LICENSE file for details.

## Support

For issues and questions:
- Create GitHub issues for bugs and feature requests
- Review existing documentation
- Check VMware and Packer documentation for platform-specific issues

## Acknowledgments

- CISA NCATS team for MESA toolkit development
- HashiCorp for Packer automation platform
- Ansible community for provisioning tools
- Debian project for stable base OS
