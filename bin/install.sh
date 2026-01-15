#!/usr/bin/env bash
set -euo pipefail

# Cognitify installer
# (c) 2026 Ramon Brooker <rbrooker@aeo3.io>

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/src"
CONFIG_SRC="$SRC_DIR/bash.bashrc.d"
HOME_FILES_SRC="$SRC_DIR/home-files"
COMPLETIONS_SRC="$SRC_DIR/completions"
PACKAGES_DIR="$SRC_DIR/packages"

CONFIG_DEST="/etc/bash.bashrc.d"
COMPLETIONS_DEST="/etc/bash_completion.d"
GROUP_NAME="cognitify"
TARGET_USER="${SUDO_USER:-${USER}}"
INCLUDE_GUI=false
SKIP_PACKAGES=false

usage() {
    cat <<USAGE
Usage: sudo bin/install.sh [options]

Options:
  --user <name>        Install dotfiles for a specific user (default: ${TARGET_USER}).
  --include-gui        Install GUI-related packages when available for the distro.
  --skip-packages      Skip package installation entirely.
  -h, --help           Show this help message.
USAGE
}

log() { printf "[cognitify] %s\n" "$*"; }
error() { printf "[cognitify] ERROR: %s\n" "$*" >&2; }

require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This installer must be run as root (try again with sudo)."
        exit 1
    fi
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --user)
                TARGET_USER="$2"
                shift 2
                ;;
            --include-gui)
                INCLUDE_GUI=true
                shift
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                usage
                exit 1
                ;;
        esac
    done
}

assert_paths() {
    for path in "$CONFIG_SRC" "$HOME_FILES_SRC" "$COMPLETIONS_SRC"; do
        if [[ ! -d $path ]]; then
            error "Required directory missing: $path"
            exit 1
        fi
    done
}

get_pkg_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt-get"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    else
        echo ""
    fi
}

read_packages() {
    local file="$1"
    [[ -f $file ]] || return 0
    awk 'NF && $1 !~ /^#/ { for (i = 1; i <= NF; ++i) if ($i !~ /^#/) print $i }' "$file"
}

collect_packages() {
    local manager="$1"
    local manager_file=""
    case "$manager" in
        apt-get)
            manager_file="$PACKAGES_DIR/PACKAGES_APT"
            ;;
        yum|dnf)
            manager_file="$PACKAGES_DIR/PACKAGES_YUM"
            ;;
        zypper)
            manager_file="$PACKAGES_DIR/PACKAGES_ZYPPER"
            ;;
    esac

    local -a packages=()
    while IFS= read -r pkg; do packages+=("$pkg"); done < <(read_packages "$PACKAGES_DIR/GENERAL")
    if $INCLUDE_GUI; then
        while IFS= read -r pkg; do packages+=("$pkg"); done < <(read_packages "$PACKAGES_DIR/GENERAL_GUI")
    fi
    if [[ -n $manager_file ]]; then
        while IFS= read -r pkg; do packages+=("$pkg"); done < <(read_packages "$manager_file")
    fi

    printf '%s\n' "${packages[@]}"
}

install_packages() {
    $SKIP_PACKAGES && { log "Skipping package installation."; return; }

    local manager
    manager=$(get_pkg_manager)
    if [[ -z $manager ]]; then
        log "No supported package manager detected; skipping package installation."
        return
    fi

    mapfile -t packages < <(collect_packages "$manager")
    if [[ ${#packages[@]} -eq 0 ]]; then
        log "No packages defined for manager '$manager'."
        return
    fi

    log "Installing packages using $manager..."
    case "$manager" in
        apt-get)
            apt-get update
            DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
            ;;
        yum)
            yum install -y "${packages[@]}"
            ;;
        dnf)
            dnf install -y "${packages[@]}"
            ;;
        zypper)
            zypper --non-interactive install --auto-agree-with-licenses "${packages[@]}"
            ;;
    esac
}

ensure_group() {
    if ! getent group "$GROUP_NAME" >/dev/null; then
        log "Creating group $GROUP_NAME"
        groupadd "$GROUP_NAME"
    else
        log "Group $GROUP_NAME already exists"
    fi
}

ensure_user_in_group() {
    if id -nG "$TARGET_USER" | grep -qw "$GROUP_NAME"; then
        log "User $TARGET_USER already in group $GROUP_NAME"
    else
        log "Adding $TARGET_USER to group $GROUP_NAME"
        usermod -aG "$GROUP_NAME" "$TARGET_USER"
    fi
}

install_configs() {
    install -d -m 775 -o root -g "$GROUP_NAME" "$CONFIG_DEST"
    cp -R "$CONFIG_SRC/." "$CONFIG_DEST/"
    chown -R root:"$GROUP_NAME" "$CONFIG_DEST"
    chmod -R 775 "$CONFIG_DEST"
    log "Installed bash configuration into $CONFIG_DEST"
}

install_completions() {
    install -d -m 755 "$COMPLETIONS_DEST"
    find "$COMPLETIONS_SRC" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
        install -m 644 "$file" "$COMPLETIONS_DEST/"
    done
    log "Installed shell completions into $COMPLETIONS_DEST"
}

install_home_files() {
    local user_home
    user_home=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    if [[ -z $user_home || ! -d $user_home ]]; then
        error "Unable to resolve home directory for user $TARGET_USER"
        exit 1
    fi

    for file in "$HOME_FILES_SRC"/*; do
        local base dest
        base=".$(basename "$file")"
        dest="$user_home/$base"

        if [[ -e $dest && ! -e ${dest}.orig ]]; then
            cp "$dest" "${dest}.orig"
            log "Backed up existing $base to ${base}.orig"
        fi
        cp "$file" "$dest"
        chown "$TARGET_USER":"$TARGET_USER" "$dest"
    done
    log "Installed dotfiles into $user_home"
}

main() {
    parse_args "$@"
    require_root
    assert_paths
    install_packages
    ensure_group
    ensure_user_in_group
    install_configs
    install_completions
    install_home_files
    log "Installation completed successfully."
}

main "$@"
