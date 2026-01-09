# Cognitify Build System

This document describes how to build and install Cognitify using the standard GNU autotools-style build process.

## Quick Start

```bash
./configure
make
sudo make install
```

## Build Process

### 1. Configure (`./configure`)

The configure script detects your Linux distribution and sets up the build configuration.

**Basic usage:**
```bash
./configure
```

**Options:**
- `--prefix=DIR` - Installation prefix (default: `/usr/local`)
- `--etc-dir=DIR` - System configuration directory (default: `/etc`)
- `--user=USER` - User to install dotfiles for (default: current user)
- `--include-gui` - Include GUI packages in installation
- `--skip-packages` - Skip package installation
- `--help` - Show help message

**Examples:**
```bash
# Install with GUI packages
./configure --include-gui

# Install to custom prefix
./configure --prefix=/usr

# Install for specific user
./configure --user=john

# Skip package installation (install files only)
./configure --skip-packages
```

**Environment Variables:**
You can also set these via environment variables:
- `PREFIX` - Installation prefix
- `ETC_DIR` - System configuration directory
- `INSTALL_USER` - User for dotfiles installation
- `INCLUDE_GUI` - Set to `yes` to include GUI packages
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
- Shell completions → `/etc/bash_completion.d/`
- User dotfiles → `~/.bashrc`, `~/.vimrc`, etc.
- User binaries → `/usr/local/bin/` (or `$PREFIX/bin`)
- Distro-specific files → As appropriate for your distribution
- Required packages → Via your package manager (apt-get/yum/dnf/zypper)

## Make Targets

- `make` or `make all` - Build/validate the project
- `make install` - Install all components
- `make install-config` - Install only configuration files
- `make install-completions` - Install only shell completions
- `make install-home` - Install only user dotfiles
- `make install-bin` - Install only user binaries
- `make install-distro` - Install only distro-specific files
- `make post-install` - Run post-installation script (package installation)
- `make clean` - Remove generated files (`config.mk`)
- `make uninstall` - Remove installed files (keeps backups)
- `make help` - Show all available targets

## Distribution Detection

The build system automatically detects:
- **Debian/Ubuntu/Mint** → Uses `apt-get`
- **RHEL/CentOS/Oracle Linux/Fedora/Rocky/AlmaLinux/Azure Linux/Amazon Linux** → Uses `yum` or `dnf`
- **openSUSE/SLES** → Uses `zypper`

## Package Installation

After installing files, the post-installation script (`post-install.sh`) automatically installs required packages using your distribution's package manager.

**Package files:**
- `src/packages/GENERAL` - Packages common to all distributions
- `src/packages/GENERAL_GUI` - GUI packages (optional, use `--include-gui`)
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
- Remove completions
- Remove user dotfiles (but restore `.orig` backups if they exist)
- Keep package installations (they are not removed)

## Troubleshooting

### "config.mk not found"
Run `./configure` first to generate the configuration file.

### "Permission denied"
Installation requires root privileges. Use `sudo make install`.

### "No supported package manager detected"
Your distribution may not be supported, or package managers are not in PATH. You can skip package installation with `--skip-packages`.

### Packages fail to install
Check your package manager configuration and network connectivity. The installation will continue even if some packages fail.

## Advanced Usage

### Custom Installation Paths

```bash
./configure --prefix=/opt/cognitify --etc-dir=/opt/etc
make
sudo make install
```

### Development Installation

```bash
./configure --prefix=$HOME/.local
make
make install  # No sudo needed for user prefix
```

### Package Installation Only

If you've already installed files and just want to install packages:

```bash
sudo make post-install
```

## Version Information

The version is read from the `version` file. After installation, the version is stored in `/etc/bash.bashrc.d/.cognitify-version`.

## Support

For issues or questions, please refer to the main README.md or open an issue in the repository.

