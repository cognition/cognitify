# Cognitify

Cognitify is a set of Linux shell customisations packaged for easy reuse across systems. It ships with shared `/etc/bash.bashrc.d` fragments, isolated prompt configuration files, user-level dotfiles, completions for common CLI tools, and curated package lists for yum/dnf-based distributions.

## What's in the box

- **Bash runtime fragments** (`src/bash.bashrc.d`): prompt, environment, alias, and function snippets intended for `/etc/bash.bashrc.d`.
- **User dotfiles** (`src/home-files`): templates for `.bashrc`, `.bash_logout`, `.gitconfig`, `.vimrc`, and other helpful defaults.
- **Shell completions** (`src/completions`): upstream completion files for tools such as `kubectl`, `helm`, `terraform`, `nerdctl`, and more.
- **Package manifests** (`src/packages`): general CLI and GUI package sets plus package-manager-specific add-ons for apt, yum/dnf, and zypper.
- **Installer** (`bin/install.sh`): bootstraps packages, installs system-wide Bash configuration, copies completions, and syncs dotfiles for the chosen user.

## Installation

Run the installer as root (or via `sudo`) from the repository root:

```bash
sudo bin/install.sh [--user <name>] [--include-gui] [--skip-packages]
```

Flags:

- `--user <name>`: install dotfiles for a specific user (defaults to `SUDO_USER` or the invoking user).
- `--include-gui`: include optional GUI tools from `src/packages/GENERAL_GUI` when installing packages.
- `--skip-packages`: skip package installation entirely.

What the installer does:

1. Detects a supported package manager (apt, yum, dnf, or zypper) and installs packages defined in `src/packages/GENERAL`, the distro-specific manifest, and optional GUI packages. Fully supports RHEL (Red Hat Enterprise Linux).
2. Creates (or reuses) the `cognitify` group, adds the target user to it, and installs `/etc/bash.bashrc.d` fragments with `root:cognitify` ownership.
3. Copies completions into `/etc/bash_completion.d`.
4. Copies dotfiles into the target user's home directory, backing up any existing files to `.orig` once.

## Maintenance

- Repository version is tracked in `version` and release notes live in `changelog/`.
- Place machine- or user-specific overrides inside `private/` to keep them out of source control.

(c) 2026 Ramon Brooker <rbrooker@aeo3.io>
