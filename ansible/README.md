# Ansible: install Cognitify

This directory contains a small **role** (`roles/cognitify`) and an example playbook that run `./configure`, `make`, and `make install` on managed hosts.

## Requirements

- Ansible 2.14 or newer on the controller
- Linux targets with a supported package manager (the Cognitify `post-install.sh` logic applies after `make install`)
- For `cognitify_deploy_method: git`: valid `cognitify_git_repo` reachable from the host
- For `cognitify_deploy_method: copy`: `cognitify_controller_source` set to the repository root **on the Ansible controller** (the machine running `ansible-playbook`)

## Quick start (copy from this checkout)

From the repository root (parent of `ansible/`):

```bash
cd ansible
ansible-playbook -i inventory/hosts.example.ini playbooks/install.yml \
  -e cognitify_deploy_method=copy \
  -e cognitify_controller_source="$(pwd)/.."
```

Use a real inventory file instead of the example when targeting remote hosts.

## Variables (summary)

See `roles/cognitify/defaults/main.yml` for defaults. Common overrides:

| Variable | Purpose |
|----------|---------|
| `cognitify_deploy_method` | `git` or `copy` |
| `cognitify_git_repo` / `cognitify_git_version` | Git source when using `git` |
| `cognitify_controller_source` | Absolute path to repo root on the controller when using `copy` |
| `cognitify_install_dir` | Where sources live on the host (default `/opt/cognitify`) |
| `cognitify_package_target` | `host`, `docker`, or `gui` (ignored if `cognitify_skip_packages`) |
| `cognitify_skip_packages` | Skip distro package installation (`configure --skip-packages`) |
| `cognitify_include_cockpit` | Add `--include-cockpit` |
| `cognitify_install_user` | User for dotfiles (`configure --user=`) |

## Idempotency

The role runs `configure`, `make`, and `make install` each time. For image builds or CI, point `cognitify_install_dir` at a clean path or use `--skip-tags` patterns only if you add tags later.
