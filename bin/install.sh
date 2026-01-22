#!/bin/bash

## (c) 2026
## Ramon Brooker <rbrooker@aeo3.io>
## Cognitify Fancy Prompt Installation Script

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default values
TARGET_USER=""
SKIP_USER_FILES=false
ALL_USERS=false
UPDATE_SKEL=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            TARGET_USER="$2"
            shift 2
            ;;
        --skip-user-files)
            SKIP_USER_FILES=true
            shift
            ;;
        --all-users)
            ALL_USERS=true
            shift
            ;;
        --update-skel)
            UPDATE_SKEL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --user <name>          Install dotfiles for a specific user"
            echo "  --all-users             Install dotfiles for all existing users"
            echo "  --update-skel           Update /etc/skel for new users"
            echo "  --skip-user-files       Skip installing user dotfiles"
            echo "  --help, -h              Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            exit 1
            ;;
    esac
done

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root${NC}" >&2
    exit 1
fi

# Determine target user (if not using --all-users)
if [[ "${ALL_USERS}" == "false" ]] && [[ -z "${TARGET_USER}" ]]; then
    if [[ -n "${SUDO_USER:-}" ]]; then
        TARGET_USER="${SUDO_USER}"
    else
        TARGET_USER="$(whoami)"
    fi
fi

echo -e "${GREEN}Installing Cognitify Fancy Prompt${NC}"
if [[ "${ALL_USERS}" == "true" ]]; then
    echo "Target: All existing users"
elif [[ -n "${TARGET_USER}" ]]; then
    echo "Target user: ${TARGET_USER}"
fi
if [[ "${UPDATE_SKEL}" == "true" ]]; then
    echo "Will update /etc/skel for new users"
fi
echo ""

# Create directories
echo "Creating directories..."
mkdir -p /etc/bash.bashrc.d/lib
mkdir -p /etc/prompts/lib

# Install system-wide bash configuration files
echo "Installing system-wide bash configuration..."
cp -v "${REPO_ROOT}/src/bash.bashrc.d/bashrc_file" /etc/bash.bashrc.d/bashrc_file
cp -v "${REPO_ROOT}/src/bash.bashrc.d/promptrc" /etc/bash.bashrc.d/promptrc
cp -v "${REPO_ROOT}/src/bash.bashrc.d/aliasrc" /etc/bash.bashrc.d/aliasrc
cp -v "${REPO_ROOT}/src/bash.bashrc.d/lib/cognitifyColours" /etc/bash.bashrc.d/lib/cognitifyColours
cp -v "${REPO_ROOT}/src/bash.bashrc.d/cognitify-me.sh" /etc/bash.bashrc.d/cognitify-me.sh

# Also copy to /etc/prompts for promptrc compatibility
cp -v "${REPO_ROOT}/src/bash.bashrc.d/lib/cognitifyColours" /etc/prompts/lib/cognitifyColours

# Set permissions
chown root:root /etc/bash.bashrc.d/bashrc_file
chown root:root /etc/bash.bashrc.d/promptrc
chown root:root /etc/bash.bashrc.d/aliasrc
chown root:root /etc/bash.bashrc.d/lib/cognitifyColours
chown root:root /etc/bash.bashrc.d/cognitify-me.sh
chown root:root /etc/prompts/lib/cognitifyColours

chmod 644 /etc/bash.bashrc.d/bashrc_file
chmod 644 /etc/bash.bashrc.d/promptrc
chmod 644 /etc/bash.bashrc.d/aliasrc
chmod 644 /etc/bash.bashrc.d/lib/cognitifyColours
chmod 755 /etc/bash.bashrc.d/cognitify-me.sh
chmod 644 /etc/prompts/lib/cognitifyColours

echo -e "${GREEN}System-wide configuration installed${NC}"
echo ""

# Function to install user dotfiles
install_user_files() {
    local user="$1"
    local user_home="$2"
    
    echo "Installing user dotfiles for ${user}..."
    
    # Backup existing files
    for file in bashrc profile; do
        if [[ -f "${user_home}/.${file}" ]] && [[ ! -f "${user_home}/.${file}.orig" ]]; then
            cp -v "${user_home}/.${file}" "${user_home}/.${file}.orig"
        fi
    done
    
    # Install new files
    cp -v "${REPO_ROOT}/src/home-files/bashrc" "${user_home}/.bashrc"
    cp -v "${REPO_ROOT}/src/home-files/profile" "${user_home}/.profile"
    
    # Copy over-ride template if it doesn't exist
    if [[ ! -f "${user_home}/.over-ride" ]]; then
        cp -v "${REPO_ROOT}/src/home-files/over-ride" "${user_home}/.over-ride"
        chown "${user}:${user}" "${user_home}/.over-ride"
    fi
    
    chown "${user}:${user}" "${user_home}/.bashrc"
    chown "${user}:${user}" "${user_home}/.profile"
}

# Update skeleton directory for new users
if [[ "${UPDATE_SKEL}" == "true" ]]; then
    echo "Updating skeleton directory (/etc/skel)..."
    mkdir -p /etc/skel
    
    # Backup existing skeleton files
    for file in bashrc profile; do
        if [[ -f "/etc/skel/.${file}" ]] && [[ ! -f "/etc/skel/.${file}.orig" ]]; then
            cp -v "/etc/skel/.${file}" "/etc/skel/.${file}.orig"
        fi
    done
    
    # Install skeleton files
    cp -v "${REPO_ROOT}/src/home-files/bashrc" /etc/skel/.bashrc
    cp -v "${REPO_ROOT}/src/home-files/profile" /etc/skel/.profile
    
    # Copy over-ride template to skeleton
    cp -v "${REPO_ROOT}/src/home-files/over-ride" /etc/skel/.over-ride
    
    chown root:root /etc/skel/.bashrc
    chown root:root /etc/skel/.profile
    chown root:root /etc/skel/.over-ride
    
    echo -e "${GREEN}Skeleton directory updated${NC}"
    echo ""
fi

# Install user dotfiles
if [[ "${SKIP_USER_FILES}" == "false" ]]; then
    if [[ "${ALL_USERS}" == "true" ]]; then
        # Install for all existing users
        echo "Installing dotfiles for all existing users..."
        
        # Get all users with home directories
        while IFS=: read -r username _ _ _ _ home_dir _; do
            # Skip system users (UID < 1000) and users without home directories
            if [[ -n "${home_dir}" ]] && [[ -d "${home_dir}" ]] && [[ "${home_dir}" != "/" ]]; then
                user_uid=$(getent passwd "${username}" | cut -d: -f3)
                if [[ "${user_uid}" -ge 1000 ]] || [[ "${username}" == "root" ]]; then
                    install_user_files "${username}" "${home_dir}"
                fi
            fi
        done < /etc/passwd
        
        echo -e "${GREEN}User dotfiles installed for all users${NC}"
    elif [[ -n "${TARGET_USER}" ]]; then
        # Install for specific user
        USER_HOME=$(getent passwd "${TARGET_USER}" | cut -d: -f6)
        
        if [[ -z "${USER_HOME}" ]]; then
            echo -e "${YELLOW}Warning: User ${TARGET_USER} not found, skipping user files${NC}"
        else
            install_user_files "${TARGET_USER}" "${USER_HOME}"
            echo -e "${GREEN}User dotfiles installed${NC}"
        fi
    fi
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
if [[ "${UPDATE_SKEL}" == "true" ]]; then
    echo "New users will automatically get the configuration from /etc/skel"
fi
echo "To activate the new prompt and aliases:"
echo "  1. Start a new shell session, or"
echo "  2. Run: source ~/.bashrc"
echo ""
echo "To customize your prompt, edit: ~/.over-ride"
