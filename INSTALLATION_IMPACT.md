# Installation Impact Documentation

This document describes in detail what happens to a system when Cognitify Fancy Prompt is installed.

## Overview

Cognitify Fancy Prompt installation modifies system-wide bash configuration and optionally user-specific dotfiles. It does **not**:
- Create system groups
- Install packages
- Modify system services
- Change system users
- Modify system-wide environment variables (except those in `/etc/bash.bashrc.d/`)

## System-Wide Changes

### Directories Created

The following directories are created if they don't exist:

1. `/etc/bash.bashrc.d/`
   - Purpose: System-wide bash configuration fragments
   - Permissions: `0755` (drwxr-xr-x)
   - Owner: `root:root`

2. `/etc/bash.bashrc.d/lib/`
   - Purpose: Library files for bash configuration
   - Permissions: `0755` (drwxr-xr-x)
   - Owner: `root:root`

3. `/etc/prompts/`
   - Purpose: Prompt configuration files (for compatibility)
   - Permissions: `0755` (drwxr-xr-x)
   - Owner: `root:root`

4. `/etc/prompts/lib/`
   - Purpose: Prompt library files
   - Permissions: `0755` (drwxr-xr-x)
   - Owner: `root:root`

### System Files Installed

The following files are installed to `/etc/bash.bashrc.d/`:

1. **`/etc/bash.bashrc.d/bashrc_file`**
   - Source: `src/bash.bashrc.d/bashrc_file`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Main entry point that sources promptrc and aliasrc
   - Impact: Loaded by system `/etc/bash.bashrc` (if configured)

2. **`/etc/bash.bashrc.d/promptrc`**
   - Source: `src/bash.bashrc.d/promptrc`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Prompt configuration and PS1 setup
   - Impact: Sets prompt for all users when sourced

3. **`/etc/bash.bashrc.d/aliasrc`**
   - Source: `src/bash.bashrc.d/aliasrc`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Alias definitions
   - Impact: Provides aliases to all users when sourced

4. **`/etc/bash.bashrc.d/lib/cognitifyColours`**
   - Source: `src/bash.bashrc.d/lib/cognitifyColours`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Color variable definitions
   - Impact: Exports color variables for use in prompts

5. **`/etc/bash.bashrc.d/cognitify-me.sh`**
   - Source: `src/bash.bashrc.d/cognitify-me.sh`
   - Permissions: `0755` (-rwxr-xr-x)
   - Owner: `root:root`
   - Purpose: User self-installation script
   - Impact: Allows users to install dotfiles without root access

6. **`/etc/prompts/lib/cognitifyColours`**
   - Source: `src/bash.bashrc.d/lib/cognitifyColours` (symlink/copy)
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Color definitions for promptrc compatibility
   - Impact: Used by promptrc if `/etc/prompts/lib/` path is preferred

### System Integration

**Note:** The system-wide files are installed but **not automatically sourced** unless:

1. The system's `/etc/bash.bashrc` sources `/etc/bash.bashrc.d/*` (common on Debian/Ubuntu)
2. Users' `.bashrc` files source `/etc/bash.bashrc.d/bashrc_file` (via installed dotfiles)
3. Users manually source the files

## User-Specific Changes (Optional)

### When Installing for Specific Users

When using `--user <name>` or `--all-users`, the following changes occur:

#### Files Installed to User Home Directories

1. **`~/.bashrc`**
   - Source: `src/home-files/bashrc`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `<username>:<username>`
   - Purpose: Sources system-wide bashrc_file
   - Backup: Existing file backed up to `~/.bashrc.orig` (once)

2. **`~/.profile`**
   - Source: `src/home-files/profile`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `<username>:<username>`
   - Purpose: Sources .bashrc for login shells
   - Backup: Existing file backed up to `~/.profile.orig` (once)

3. **`~/.over-ride`**
   - Source: `src/home-files/over-ride`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `<username>:<username>`
   - Purpose: User customization file for prompt colors
   - Backup: **Not backed up** if file already exists (preserves user customizations)

### When Using `--all-users`

The installer processes all users from `/etc/passwd` where:
- UID >= 1000, OR
- Username is `root`
- User has a valid home directory
- Home directory exists and is not `/`

Each qualifying user gets the same files installed as described above.

### When Using `--update-skel`

The following files are installed to `/etc/skel/`:

1. **`/etc/skel/.bashrc`**
   - Source: `src/home-files/bashrc`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Template for new users
   - Backup: Existing file backed up to `/etc/skel/.bashrc.orig` (once)

2. **`/etc/skel/.profile`**
   - Source: `src/home-files/profile`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Template for new users
   - Backup: Existing file backed up to `/etc/skel/.profile.orig` (once)

3. **`/etc/skel/.over-ride`**
   - Source: `src/home-files/over-ride`
   - Permissions: `0644` (-rw-r--r--)
   - Owner: `root:root`
   - Purpose: Template for new users
   - Backup: **Not created** if file already exists

**Impact:** New users created after installation will automatically receive these files in their home directories.

## File Backup Behavior

### Backup Strategy

- **Existing files are backed up ONCE** to `.orig` extension
- If `.orig` file already exists, it is **not overwritten**
- This prevents loss of user customizations on re-installation

### Files That Are Backed Up

- `~/.bashrc` → `~/.bashrc.orig`
- `~/.profile` → `~/.profile.orig`
- `/etc/skel/.bashrc` → `/etc/skel/.bashrc.orig`
- `/etc/skel/.profile` → `/etc/skel/.profile.orig`

### Files That Are NOT Backed Up

- `~/.over-ride` (if it already exists, it's preserved)
- System-wide files in `/etc/bash.bashrc.d/` (overwritten on re-installation)

## Environment Variables Set

### System-Wide Variables (from promptrc)

When promptrc is sourced, the following variables are set:

- `PS1` - Primary prompt string (varies by user/root/WSL)
- `color_prompt` - Color prompt flag (temporary, unset after use)
- `BASE_PATH` - Path to bash.bashrc.d (set in bashrc_file)
- `COGNITIFY_VERSION` - Version string "0.2.0-fancy-prompt"

### Color Variables (from cognitifyColours)

Exported color variables include:
- `COLOUR`, `RESET`, `BOLD`
- `ROOT_RED`, `OLIVE`, `LT_BLUE`, `PINK`, `BRIGHT_PINK`
- `AZURE`, `GREEN`, `GOLD`, `ORANGE`, `LIME`, `GRAY`
- `OFF_WHITE`, `WARM_WHITE`, `EASY_WHITE`
- `LS_COLORS`, `GCC_COLORS`

### User Override Variables (from ~/.over-ride)

Users can set:
- `OVERRIDE_HOSTNAME_COLOUR`
- `OVERRIDE_USERNAME_COLOUR`
- `OVERRIDE_PWD_COLOUR`
- `OVERRIDE_SUDO_USER_COLOUR`
- `OVERRIDE_SQUARE_BRACKETS`
- `HOSTNAME_NUMBER`

## Shell Behavior Changes

### Prompt Appearance

After installation, users will see:
- Colored hostname in brackets: `[hostname]`
- Colored username
- Colored working directory path
- SUDO_USER indicator (when using `sudo -u`)
- Root warning message (when running as root, unless suppressed)

### Aliases Available

Users gain access to numerous aliases including:
- Enhanced `ls`, `grep`, `dir` commands with color
- Navigation shortcuts (`..`, `x`, `clean`)
- System management (`psgrep`, `srvs`)
- Networking (`established`, `listening`, etc.)
- Docker aliases (if docker installed)
- Git aliases (if git installed)

## What Does NOT Happen

The installation **does not**:

- ❌ Create system groups (`cognitify` or any other)
- ❌ Add users to groups
- ❌ Install packages or dependencies
- ❌ Modify system services
- ❌ Change system users or passwords
- ❌ Modify `/etc/passwd` or `/etc/group`
- ❌ Install completions to `/etc/bash_completion.d/`
- ❌ Modify system-wide `/etc/bash.bashrc` (only creates files in `/etc/bash.bashrc.d/`)
- ❌ Modify `/etc/environment` or `/etc/profile`
- ❌ Create systemd services or timers
- ❌ Modify firewall rules
- ❌ Change network configuration
- ❌ Install kernel modules
- ❌ Modify boot configuration

## Rollback Procedure

### To Remove System-Wide Installation

```bash
# Remove system files
rm -rf /etc/bash.bashrc.d/bashrc_file
rm -rf /etc/bash.bashrc.d/promptrc
rm -rf /etc/bash.bashrc.d/aliasrc
rm -rf /etc/bash.bashrc.d/lib/cognitifyColours
rm -rf /etc/bash.bashrc.d/cognitify-me.sh
rm -rf /etc/prompts/lib/cognitifyColours

# Remove directories if empty
rmdir /etc/bash.bashrc.d/lib 2>/dev/null || true
rmdir /etc/bash.bashrc.d 2>/dev/null || true
rmdir /etc/prompts/lib 2>/dev/null || true
rmdir /etc/prompts 2>/dev/null || true
```

### To Restore User Files

```bash
# For individual user
mv ~/.bashrc.orig ~/.bashrc
mv ~/.profile.orig ~/.profile
# .over-ride is not backed up, so manually remove if desired
rm ~/.over-ride
```

### To Restore Skeleton Directory

```bash
mv /etc/skel/.bashrc.orig /etc/skel/.bashrc
mv /etc/skel/.profile.orig /etc/skel/.profile
rm /etc/skel/.over-ride
```

## Verification

### Check System Installation

```bash
# Verify system files exist
ls -la /etc/bash.bashrc.d/
ls -la /etc/prompts/lib/

# Check file permissions
stat /etc/bash.bashrc.d/bashrc_file
stat /etc/bash.bashrc.d/promptrc
stat /etc/bash.bashrc.d/aliasrc
```

### Check User Installation

```bash
# Verify user files
ls -la ~/.bashrc ~/.profile ~/.over-ride

# Check if backups exist
ls -la ~/.bashrc.orig ~/.profile.orig
```

### Test Functionality

```bash
# Source the configuration
source /etc/bash.bashrc.d/bashrc_file

# Check version
echo $COGNITIFY_VERSION

# Check prompt
echo $PS1

# Test aliases
alias | grep -E 'ls|grep|docker|git'
```

## Impact Summary

| Component | Impact Level | Reversible | Requires Reboot |
|-----------|--------------|------------|-----------------|
| System directories | Low | Yes | No |
| System files | Low | Yes | No |
| User dotfiles | Medium | Yes | No |
| Skeleton directory | Medium | Yes | No |
| Environment variables | Low | Yes | No |
| Shell behavior | Medium | Yes | No |

**Overall Impact:** Low to Medium - All changes are file-based and easily reversible.

(c) 2026 Ramon Brooker <rbrooker@aeo3.io>
