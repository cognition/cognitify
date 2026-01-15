# Ansible Playbook Installation

This directory contains an Ansible playbook to install Cognitify on remote systems.

## Prerequisites

- Ansible 2.9 or later
- SSH access to target hosts with sudo privileges
- Target systems must support yum or dnf package managers

## Quick Start

1. Create an inventory file (or use the example):

```bash
cp ansible-inventory.example inventory
# Edit inventory with your target hosts
```

2. Run the playbook:

```bash
ansible-playbook -i inventory install.yml
```

## Usage Examples

### Basic Installation

Install for the default user (ansible_user):

```bash
ansible-playbook -i inventory install.yml
```

### Install for Specific User

```bash
ansible-playbook -i inventory install.yml -e "install_user=myuser"
```

### Skip Package Installation

```bash
ansible-playbook -i inventory install.yml -e "skip_packages=true"
```

### Set Hostname Colour

```bash
ansible-playbook -i inventory install.yml -e "hostname_colour=AZURE"
```

### Multiple Variables

```bash
ansible-playbook -i inventory install.yml \
  -e "install_user=john" \
  -e "skip_packages=false" \
  -e "hostname_colour=BRIGHT_PINK"
```

### Test on Localhost

```bash
ansible-playbook -i "localhost," -c local install.yml --become
```

## Variables

The playbook supports the following variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `install_user` | `ansible_user` | User to install dotfiles for |
| `skip_packages` | `false` | Skip package installation |
| `docker_mode` | `false` | Use Docker/container mode (not fully implemented) |
| `hostname_colour` | `""` | Set default hostname colour (e.g., AZURE, BRIGHT_PINK, OLIVE) |

## What Gets Installed

The playbook installs:

1. **System Packages**: From `src/packages/GENERAL` and `src/packages/PACKAGES_YUM`
2. **Bash Configuration**: Files from `src/bash.bashrc.d` to `/etc/bash.bashrc.d`
3. **Prompt Configuration**: Files from `src/prompts` to `/etc/prompts`
4. **Shell Completions**: Files from `src/completions` to `/etc/bash_completion.d`
5. **User Dotfiles**: Files from `src/home-files` to user's home directory
6. **Binaries**: Scripts from `src/usr/local/bin` to `/usr/local/bin`
7. **Documentation**: From `docs/` to `/usr/local/share/doc/cognitify`
8. **Man Pages**: From `man/man1/` to `/usr/local/share/man/man1`
9. **Profile Scripts**: From `src/profile.d` to `/etc/profile.d`
10. **Skel Files**: Dotfiles to `/etc/skel` for new users

## Post-Installation

After installation, users should log out and log back in for shell customisations to take effect.

## Troubleshooting

### Package Manager Not Detected

If you see an error about unsupported package manager, ensure your target system has `yum` or `dnf` installed and accessible.

### User Does Not Exist

Ensure the `install_user` exists on the target system before running the playbook.

### Permission Errors

Ensure the ansible user has sudo privileges on target hosts. You may need to use `--become` flag:

```bash
ansible-playbook -i inventory install.yml --become
```

## See Also

- Main README.md for general Cognitify information
- `bin/install.sh` for manual installation script
- `configure` script for Makefile-based installation

(c) 2026 Ramon Brooker <rbrooker@aeo3.io>
