# Ansible Fleet Deployment Guide

This guide explains how to deploy Cognitify across a fleet of machines with consistent or random colour profiles.

## Overview

The Ansible playbook now supports:
- **Random colour profiles** - Each machine gets a unique random colour scheme
- **Fleet-wide standard colours** - All machines use the same colour scheme
- **Multi-user installation** - Install for all users on a system
- **Environment-specific configurations** - Different colours per environment

## Key Features

### 1. Random Colour Profile Support

When `colour_profile=random` is set, the playbook will:
- Parse `colour-combos.md` file
- Randomly select one of 41 available colour combinations
- Set `hostname_colour`, `username_colour`, and `pwd_colour` automatically
- Apply colours to system-wide config (`/etc/prompts/config`)
- Apply colours to each user's `~/.over-ride` file

### 2. Multi-User Installation

When `install_all_users=true` is set, the playbook will:
- Install dotfiles for all users with UID >= 1000 (or root)
- Skip system users (nologin/false shells)
- Apply colour settings to each user's `~/.over-ride` file
- Ensure all users are in the `cognitify` group

### 3. Fleet-Wide Standard Colours

Set the same colours across all machines:
- System-wide config (`/etc/prompts/config`) gets the colours
- Each user's `~/.over-ride` gets the colours
- Consistent experience across the entire fleet

## Usage Examples

### Example 1: Fleet-Wide Standard Colours

Deploy the same colour scheme to all machines and all users:

```bash
ansible-playbook -i inventory install.yml \
  -e "install_all_users=true" \
  -e "hostname_colour=AZURE" \
  -e "username_colour=LIME" \
  -e "pwd_colour=AZURE"
```

**Result:**
- All machines get the same colours
- All users on each machine get the same colours
- Consistent experience fleet-wide

### Example 2: Random Colours Per Machine

Give each machine a unique random colour scheme:

```bash
ansible-playbook -i inventory install.yml \
  -e "install_all_users=true" \
  -e "colour_profile=random"
```

**Result:**
- Each machine gets a different random colour combination
- All users on the same machine get the same colours
- Unique visual identity per machine

### Example 3: Random Colours Per User

For truly unique colours per user (requires custom playbook):

```yaml
- name: Install with random colours per user
  hosts: all
  become: yes
  tasks:
    - name: Install for each user with random colours
      include_tasks: install.yml
      vars:
        install_user: "{{ item.key }}"
        colour_profile: "random"
      loop: "{{ ansible_facts.getent_passwd | dict2items }}"
      when:
        - item.value[1] | int >= 1000 or item.key == "root"
```

### Example 4: Environment-Specific Colours

Use group variables for different environments:

**group_vars/production.yml:**
```yaml
cognitify_hostname_colour: "AZURE"
cognitify_username_colour: "LIME"
cognitify_pwd_colour: "AZURE"
cognitify_install_all_users: true
```

**group_vars/staging.yml:**
```yaml
cognitify_colour_profile: "random"
cognitify_install_all_users: true
```

**group_vars/development.yml:**
```yaml
cognitify_hostname_colour: "BRIGHT_PINK"
cognitify_username_colour: "GOLD"
cognitify_pwd_colour: "BRIGHT_PINK"
cognitify_install_all_users: true
```

**Playbook:**
```yaml
- name: Install Cognitify
  hosts: all
  become: yes
  tasks:
    - include_tasks: install.yml
      vars:
        hostname_colour: "{{ cognitify_hostname_colour | default('') }}"
        username_colour: "{{ cognitify_username_colour | default('') }}"
        pwd_colour: "{{ cognitify_pwd_colour | default('') }}"
        colour_profile: "{{ cognitify_colour_profile | default('') }}"
        install_all_users: "{{ cognitify_install_all_users | default(false) }}"
```

**Deploy:**
```bash
# Production - standard colours
ansible-playbook -i inventory install.yml --limit production

# Staging - random colours
ansible-playbook -i inventory install.yml --limit staging

# Development - custom colours
ansible-playbook -i inventory install.yml --limit development
```

## Variable Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `install_user` | string | `ansible_user` | Single user to install for |
| `install_all_users` | boolean | `false` | Install for all users (UID >= 1000) |
| `hostname_colour` | string | `""` | Hostname colour (e.g., AZURE, BRIGHT_PINK) |
| `username_colour` | string | `""` | Username colour (e.g., LIME, GRAY) |
| `pwd_colour` | string | `""` | PWD colour (e.g., AZURE, LT_BLUE) |
| `colour_profile` | string | `""` | Set to `random` for random selection |
| `skip_packages` | boolean | `false` | Skip package installation |
| `docker_mode` | boolean | `false` | Docker/container mode |

## How It Works

### Random Colour Selection

1. Playbook checks for `colour-combos.md` or `colour-combos` file
2. Parses file to extract valid colour combinations (3 colours per line)
3. Uses `shuf` (or fallback) to randomly select one combination
4. Sets `hostname_colour`, `username_colour`, and `pwd_colour` variables
5. These variables are then used throughout the playbook

### Multi-User Installation

1. Uses `getent` to retrieve all users from `/etc/passwd`
2. Filters users:
   - UID >= 1000 OR user is root
   - Shell is not nologin/false
   - Home directory exists
3. For each valid user:
   - Installs dotfiles to their home directory
   - Updates `~/.over-ride` with colour settings
   - Adds user to `cognitify` group

### Colour Application

Colours are applied in two places:

1. **System-wide** (`/etc/prompts/config`):
   - Applied to all users by default
   - Can be overridden by user-specific settings

2. **User-specific** (`~/.over-ride`):
   - Applied to individual users
   - Takes precedence over system-wide settings
   - Updated via `blockinfile` module (idempotent)

## Best Practices

### For Fleet Consistency

```bash
# Use the same colours across all machines
ansible-playbook -i inventory install.yml \
  -e "install_all_users=true" \
  -e "hostname_colour=AZURE" \
  -e "username_colour=LIME" \
  -e "pwd_colour=AZURE"
```

### For Machine Identification

```bash
# Each machine gets unique random colours
ansible-playbook -i inventory install.yml \
  -e "install_all_users=true" \
  -e "colour_profile=random"
```

### For Environment Differentiation

Use group variables to set different colours per environment:
- Production: Professional colours (AZURE, GRAY, LT_BLUE)
- Staging: Random for testing
- Development: Bright colours (BRIGHT_PINK, GOLD, etc.)

## Troubleshooting

### Random Selection Not Working

- Ensure `colour-combos.md` exists in the playbook directory
- Check that `shuf` command is available on target systems
- Verify file permissions allow reading the file

### Users Not Getting Colours

- Check that `install_all_users=true` is set
- Verify users meet criteria (UID >= 1000, valid shell)
- Check that colour variables are set correctly
- Review playbook output for errors

### Inconsistent Colours

- If using random, each machine gets different colours
- For consistency, specify colours explicitly
- Check group variables aren't overriding settings

## See Also

- `ANSIBLE.md` - General Ansible playbook documentation
- `ansible-examples.yml` - Complete example playbooks
- `colour-combos.md` - Available colour combinations
- `configure` - Manual installation script

(c) 2026 Ramon Brooker <rbrooker@aeo3.io>
