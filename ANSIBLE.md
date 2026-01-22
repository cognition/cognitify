# Ansible Deployment Guide

This guide explains how to deploy Cognitify Fancy Prompt using Ansible.

## Prerequisites

- Ansible installed on your control machine
- SSH access to target hosts
- Sudo/root access on target hosts

## Quick Start

1. **Create an inventory file** based on `ansible-inventory.example`:
   ```bash
   cp ansible-inventory.example ansible-inventory
   # Edit ansible-inventory with your hosts
   ```

2. **Deploy to all hosts**:
   ```bash
   ansible-playbook -i ansible-inventory install.yml
   ```

3. **Deploy user files only** (if system files already installed):
   ```bash
   ansible-playbook -i ansible-inventory install-user-files.yml
   ```

## Playbooks

### `install.yml`
Full installation playbook that installs:
- System-wide bash configuration files (`/etc/bash.bashrc.d/`)
- Prompt configuration files (`/etc/prompts/`)
- User dotfiles (`.bashrc`, `.profile`, `.over-ride`)

### `install-user-files.yml`
User files only playbook for when system files are already installed.

## Variables

### `cognitify_user`
Target user for dotfile installation. Defaults to `ansible_user`.

### `cognitify_skip_user_files`
Set to `true` to skip user dotfile installation. Defaults to `false`.

### `cognitify_all_users`
Set to `true` to install dotfiles for all existing users (UID >= 1000 or root). Defaults to `false`.

### `cognitify_update_skel`
Set to `true` to update `/etc/skel` so new users automatically get the configuration. Defaults to `false`.

## Examples

### Install for specific user
```bash
ansible-playbook -i ansible-inventory install.yml -e "cognitify_user=john"
```

### System-wide only (no user files)
```bash
ansible-playbook -i ansible-inventory install.yml -e "cognitify_skip_user_files=true"
```

### Install for all users
```bash
ansible-playbook -i ansible-inventory install.yml -e "cognitify_all_users=true"
```

### Update skeleton directory
```bash
ansible-playbook -i ansible-inventory install.yml -e "cognitify_update_skel=true"
```

### Deploy to specific group
```bash
ansible-playbook -i ansible-inventory install.yml --limit servers
```

## Inventory File Format

```ini
[servers]
server1.example.com
server2.example.com

[servers:vars]
ansible_user=admin
cognitify_user=admin
```

## Post-Installation

After installation, users need to:
1. Start a new shell session, or
2. Run: `source ~/.bashrc`

Users can customize their prompt by editing `~/.over-ride`.

(c) 2026 Ramon Brooker <rbrooker@aeo3.io>
