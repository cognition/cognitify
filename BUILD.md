# Cognitify Build System

This document describes how to build and install Cognitify using the standard GNU autotools-style build process.

## Quick Start

```bash
./configure --package-target=host
make
sudo make install
```

## Build Process

### 1. Configure (`./configure`)

The configure script detects your Linux distribution and sets up the build configuration.

**Basic usage:**
```bash
./configure --package-target=host
```

**Options:**
- `--prefix=DIR` - Installation prefix (default: `/usr/local`)
- `--etc-dir=DIR` - System configuration directory (default: `/etc`)
- `--user=USER` - User to install dotfiles for (default: current user)
- `--package-target=PROFILE` - Package profile when installing packages: `host`, `docker`, or `gui` (required on normal hosts unless you use `--docker`, `--include-gui`, or `--skip-packages`; inside a container, `docker` is assumed if omitted)
- `--include-gui` - Same as `--package-target=gui`
- `--docker` - Same as `--package-target=docker`
- `--include-cockpit` - Add Cockpit packages (`src/packages/COCKPIT`)
- `--skip-packages` - Skip package installation
- `--help` - Show help message

**Examples:**
```bash
# Standard server or VM (GENERAL package list)
./configure --package-target=host

# Optional Cockpit on top of host profile
./configure --package-target=host --include-cockpit

# Install with GUI packages
./configure --include-gui

# Install to custom prefix
./configure --prefix=/usr --package-target=host

# Install for specific user
./configure --user=john --package-target=host

# Skip package installation (install files only)
./configure --skip-packages
```

**Environment Variables:**
You can also set these via environment variables:
- `PREFIX` - Installation prefix
- `ETC_DIR` - System configuration directory
- `INSTALL_USER` - User for dotfiles installation
- `INCLUDE_GUI` - Set to `yes` to include GUI packages
- `PACKAGE_TARGET` - `host`, `docker`, or `gui`
- `INCLUDE_COCKPIT` - Set to `yes` to install Cockpit-related packages
- `SKIP_PACKAGES` - Set to `yes` to skip package installation

The configure script generates a `config.mk` file with all build settings.

### 2. Build (`make`)

Validates the project structure and prepares for installation.

```bash
make
```

### 3. Install (`make install`)

Installs all components and runs the post-installation script to install required packages.

```bash
sudo make install
```

**What gets installed:**
- Bash configuration files → `/etc/bash.bashrc.d/`
- Prompt configuration files → `/etc/prompts/`
- Shell completions → `/etc/bash_completion.d/`
- User dotfiles → `~/.bashrc`, `~/.vimrc`, etc.
- User binaries → `/usr/local/bin/` (or `$PREFIX/bin`)
- Distro-specific files → As appropriate for your distribution
- Required packages → Via your package manager (yum/dnf)

## Make Targets

- `make` or `make all` - Build/validate the project
- `make install` - Install all components
- `make install-config` - Install only configuration files
- `make install-prompts` - Install only prompt configuration files
- `make install-completions` - Install only shell completions
- `make install-home` - Install only user dotfiles
- `make install-home` can be run without `sudo` for the current user once `$(ETC_DIR)/bash.bashrc.d` is already installed; root is still required for `ALL=1` or another target user
- `make install-bin` - Install only user binaries
- `make install-distro` - Install only distro-specific files
- `make post-install` - Run post-installation script (package installation)
- `make clean` - Remove generated files (`config.mk`)
- `make uninstall` - Remove installed files (keeps backups)
- `make help` - Show all available targets

## Distribution Detection

The build system automatically detects:
- **RHEL (Red Hat Enterprise Linux)** → Uses `dnf` (or `yum` on older versions)
- **CentOS/Oracle Linux/Fedora/Rocky/AlmaLinux/Azure Linux/Amazon Linux** → Uses `yum` or `dnf`

**Note:** This pared-down version supports only yum/dnf-based distributions. Support for apt-get and zypper has been removed.

RHEL is fully supported and will be automatically detected whether the system reports `ID="rhel"` or `ID="redhat"` in `/etc/os-release`.

## Package Installation

After installing files, the post-installation script (`post-install.sh`) automatically installs required packages using your distribution's package manager.

**Package files:**
- `src/packages/GENERAL` - Packages common to all distributions (`--package-target=host`)
- `src/packages/GENERAL DOCKER` - Container-oriented list (`--package-target=docker` or `--docker`)
- `src/packages/GENERAL_GUI` - GUI packages (`--package-target=gui` or `--include-gui`)
- `src/packages/COCKPIT` - Cockpit packages (optional, `--include-cockpit` or `make post-install-cockpit`)
- `src/packages/PACKAGES_APT` - Debian/Ubuntu specific packages
- `src/packages/PACKAGES_YUM` - RHEL/CentOS/Fedora specific packages
- `src/packages/PACKAGES_ZYPPER` - openSUSE/SLES specific packages

## Uninstallation

To remove Cognitify:

```bash
sudo make uninstall
```

This will:
- Remove configuration files from `/etc/bash.bashrc.d/`
- Remove prompt configuration files from `/etc/prompts/`
- Remove completions
- Remove user dotfiles (but restore `.orig` backups if they exist)
- Keep package installations (they are not removed)

## Troubleshooting

### "config.mk not found"
Run `./configure` with a valid profile (for example `./configure --package-target=host` or `./configure --skip-packages`) to generate `config.mk`.

### "Permission denied"
Installation requires root privileges. Use `sudo make install`.

### "No supported package manager detected"
Your distribution may not be supported, or package managers are not in PATH. You can skip package installation with `--skip-packages`.

### Packages fail to install
Check your package manager configuration and network connectivity. The installation will continue even if some packages fail.

## Advanced Usage

### Custom Installation Paths

```bash
./configure --prefix=/opt/cognitify --etc-dir=/opt/etc --package-target=host
make
sudo make install
```

### Development Installation

```bash
./configure --prefix=$HOME/.local --skip-packages
make
make install  # No sudo needed for user prefix
```

### Package Installation Only

If you've already installed files and just want to install packages:

```bash
sudo make post-install
```

## Version Information

The version is read from the `version` file. After installation, the version is stored in:
- `/etc/bash.bashrc.d/.cognitify-version`
- `/etc/prompts/.cognitify-version`

## Support

For issues or questions, please refer to the main README.md or open an issue in the repository.

