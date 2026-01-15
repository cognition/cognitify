# Cognitify

Cognitify is a set of Linux shell customisations packaged for easy reuse across systems. It ships with shared `/etc/bash.bashrc.d` fragments, user-level dotfiles, completions for common CLI tools, and curated package lists for popular distributions.

## What's in the box

- **Bash runtime fragments** (`src/bash.bashrc.d`): environment, alias, and function snippets intended for `/etc/bash.bashrc.d`.
- **Prompt configuration** (`src/prompts`): isolated prompt configuration files including colour definitions, intended for `/etc/prompts`.
- **User dotfiles** (`src/home-files`): templates for `.bashrc`, `.bash_logout`, `.gitconfig`, `.vimrc`, and other helpful defaults.
- **Shell completions** (`src/completions`): completion files for common CLI tools.
- **Package manifests** (`src/packages`): general CLI package sets plus package-manager-specific add-ons for yum/dnf.
- **Installer** (`bin/install.sh`): bootstraps packages, installs system-wide Bash configuration and prompts, copies completions, and syncs dotfiles for the chosen user.

## Installation

Run the installer as root (or via `sudo`) from the repository root:

```bash
sudo bin/install.sh [--user <name>] [--skip-packages]
```

Flags:

- `--user <name>`: install dotfiles for a specific user (defaults to `SUDO_USER` or the invoking user).
- `--skip-packages`: skip package installation entirely.

What the installer does:

1. Detects a supported package manager (yum or dnf) and installs packages defined in `src/packages/GENERAL` and the distro-specific manifest (`PACKAGES_YUM`).
2. Creates (or reuses) the `cognitify` group, adds the target user to it, and installs `/etc/bash.bashrc.d` fragments with `root:cognitify` ownership.
3. Installs prompt configuration files to `/etc/prompts`.
4. Copies completions into `/etc/bash_completion.d` (if any exist).
5. Copies dotfiles into the target user's home directory, backing up any existing files to `.orig` once.

## Maintenance

- Repository version is tracked in `version` and release notes live in `changelog/`.
- Place machine- or user-specific overrides inside `private/` to keep them out of source control.

(c) 2025 Ramon Brooker <rbrooker@aeo3.io>
