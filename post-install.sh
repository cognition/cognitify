#!/usr/bin/env bash
# Cognitify post-installation script
# Installs required packages using the detected package manager
# (c) 2026 Ramon Brooker <rbrooker@aeo3.io>

set -euo pipefail

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Colour

# Arguments
PKG_MANAGER="${1:-}"
PKG_MANAGER_INSTALL="${2:-}"
PKG_MANAGER_UPDATE="${3:-}"
PACKAGES_DIR="${4:-src/packages}"
INCLUDE_GUI="${5:-no}"
DOCKER_MODE="${6:-no}"

log() {
    printf "${GREEN}[cognitify]${NC} %s\n" "$*" >&2
}

error() {
    printf "${RED}[cognitify] ERROR:${NC} %s\n" "$*" >&2
}

warn() {
    printf "${YELLOW}[cognitify] WARNING:${NC} %s\n" "$*" >&2
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (use: sudo make install)"
    exit 1
fi

# Validate arguments
if [[ -z "$PKG_MANAGER" ]] || [[ -z "$PKG_MANAGER_INSTALL" ]]; then
    error "Invalid arguments. Package manager information required."
    exit 1
fi

if [[ ! -d "$PACKAGES_DIR" ]]; then
    error "Packages directory not found: $PACKAGES_DIR"
    exit 1
fi

# Read packages from file (skip comments and empty lines)
read_packages() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    awk 'NF && $1 !~ /^#/ { 
        for (i = 1; i <= NF; ++i) {
            if ($i !~ /^#/) {
                print $i
            }
        }
    }' "$file"
}

# Collect packages based on package manager
collect_packages() {
    local -a packages=()
    local manager_file=""
    
    # Determine manager-specific package file
    case "$PKG_MANAGER" in
        yum|dnf)
            manager_file="$PACKAGES_DIR/PACKAGES_YUM"
            ;;
        *)
            warn "Package manager '$PKG_MANAGER' not supported in this pared-down version"
            ;;
    esac
    
    # Read general packages (use GENERAL DOCKER if in Docker mode)
    local general_file="$PACKAGES_DIR/GENERAL"
    if [[ "$DOCKER_MODE" = "yes" ]] && [[ -f "$PACKAGES_DIR/GENERAL DOCKER" ]]; then
        general_file="$PACKAGES_DIR/GENERAL DOCKER"
        log "Using Docker/container package list"
    fi
    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] && packages+=("$pkg")
    done < <(read_packages "$general_file")
    
    # GUI packages removed in pared-down version
    
    # Read manager-specific packages
    if [[ -n "$manager_file" ]] && [[ -f "$manager_file" ]]; then
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] && packages+=("$pkg")
        done < <(read_packages "$manager_file")
    fi
    
    # Remove duplicates and return
    printf '%s\n' "${packages[@]}" | sort -u
}

# Install packages
install_packages() {
    local -a packages
    mapfile -t packages < <(collect_packages)
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        warn "No packages defined for manager '$PKG_MANAGER'"
        return 0
    fi
    
    log "Installing packages using $PKG_MANAGER..."
    log "Packages to install: ${packages[*]}"
    
    # Update package lists
    if [[ -n "$PKG_MANAGER_UPDATE" ]]; then
        log "Updating package lists..."
        eval "$PKG_MANAGER_UPDATE" || warn "Package list update had issues (continuing anyway)"
    fi
    
    # Install packages
    case "$PKG_MANAGER" in
        yum)
            yum install -y "${packages[@]}" || {
                error "Failed to install packages"
                return 1
            }
            ;;
        dnf)
            dnf install -y "${packages[@]}" || {
                error "Failed to install packages"
                return 1
            }
            ;;
        *)
            warn "Package manager '$PKG_MANAGER' not supported in this pared-down version"
            return 0
            ;;
    esac
    
    log "Package installation completed successfully"
}

# Main
main() {
    log "Starting post-installation package installation"
    log "Package Manager: $PKG_MANAGER"
    log "Include GUI: $INCLUDE_GUI"
    log "Docker Mode: $DOCKER_MODE"
    
    install_packages
    
    log "Post-installation script completed"
}

main "$@"

