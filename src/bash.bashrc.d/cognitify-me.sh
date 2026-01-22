#!/bin/bash

## (c) 2026
## Ramon Brooker <rbrooker@aeo3.io>
## Cognitify Fancy Prompt - User Self-Install Script
##
## This script allows users to install cognitify dotfiles to their own
## home directory without requiring root access. It assumes system-wide
## files are already installed in /etc/bash.bashrc.d/

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Check if system-wide installation exists
if [[ ! -f /etc/bash.bashrc.d/bashrc_file ]]; then
    echo -e "${RED}Error: System-wide cognitify installation not found${NC}" >&2
    echo "Please ask your system administrator to install cognitify system-wide first." >&2
    echo "The system files should be in /etc/bash.bashrc.d/" >&2
    exit 1
fi

# Get current user and home directory
CURRENT_USER="${USER:-$(whoami)}"
USER_HOME="${HOME:-$(getent passwd "${CURRENT_USER}" | cut -d: -f6)}"

if [[ -z "${USER_HOME}" ]]; then
    echo -e "${RED}Error: Could not determine home directory${NC}" >&2
    exit 1
fi

echo -e "${BLUE}Cognitify Fancy Prompt - User Self-Install${NC}"
echo "Installing for user: ${CURRENT_USER}"
echo "Home directory: ${USER_HOME}"
echo ""

# Check if source files exist
if [[ ! -f "${REPO_ROOT}/src/home-files/bashrc" ]] || [[ ! -f "${REPO_ROOT}/src/home-files/profile" ]]; then
    echo -e "${YELLOW}Warning: Source files not found in repository${NC}"
    echo "Attempting to use system-installed templates..."
    
    # Try to find files in common locations
    if [[ -f /usr/share/cognitify/home-files/bashrc ]]; then
        SOURCE_DIR="/usr/share/cognitify/home-files"
    elif [[ -f /opt/cognitify/src/home-files/bashrc ]]; then
        SOURCE_DIR="/opt/cognitify/src/home-files"
    else
        echo -e "${RED}Error: Could not find source files${NC}" >&2
        echo "Please ensure you're running this from the cognitify repository directory." >&2
        exit 1
    fi
else
    SOURCE_DIR="${REPO_ROOT}/src/home-files"
fi

# Backup existing files
echo "Backing up existing files..."
for file in bashrc profile; do
    if [[ -f "${USER_HOME}/.${file}" ]] && [[ ! -f "${USER_HOME}/.${file}.orig" ]]; then
        cp -v "${USER_HOME}/.${file}" "${USER_HOME}/.${file}.orig"
        echo -e "${GREEN}Backed up ${USER_HOME}/.${file} to ${USER_HOME}/.${file}.orig${NC}"
    elif [[ -f "${USER_HOME}/.${file}.orig" ]]; then
        echo -e "${YELLOW}Backup already exists: ${USER_HOME}/.${file}.orig${NC}"
    fi
done
echo ""

# Install dotfiles
echo "Installing dotfiles..."
cp -v "${SOURCE_DIR}/bashrc" "${USER_HOME}/.bashrc"
cp -v "${SOURCE_DIR}/profile" "${USER_HOME}/.profile"

# Copy over-ride template if it doesn't exist
if [[ ! -f "${USER_HOME}/.over-ride" ]]; then
    if [[ -f "${SOURCE_DIR}/over-ride" ]]; then
        cp -v "${SOURCE_DIR}/over-ride" "${USER_HOME}/.over-ride"
        echo -e "${GREEN}Created ${USER_HOME}/.over-ride template${NC}"
    else
        echo -e "${YELLOW}Warning: over-ride template not found${NC}"
    fi
else
    echo -e "${YELLOW}.over-ride already exists, skipping${NC}"
fi

# Set permissions (user owns their own files)
chmod 644 "${USER_HOME}/.bashrc"
chmod 644 "${USER_HOME}/.profile"
if [[ -f "${USER_HOME}/.over-ride" ]]; then
    chmod 644 "${USER_HOME}/.over-ride"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "To activate the new prompt and aliases:"
echo "  1. Start a new shell session, or"
echo "  2. Run: source ~/.bashrc"
echo ""
echo "To customize your prompt, edit: ~/.over-ride"
echo ""
echo -e "${BLUE}Note: System-wide configuration is already installed.${NC}"
echo "This script only updated your personal dotfiles."
