#!/usr/bin/env bash
set -euo pipefail

# Cognitify WSL installer — user-local dotfiles and bash fragments.
# No Cockpit, packages, or system-wide install (no sudo required).
# (c) 2026 Ramon Brooker <rbrooker@aeo3.io>

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"
CONFIG_SRC="${SRC_DIR}/bash.bashrc.d"
HOME_FILES_SRC="${SRC_DIR}/home-files"
TARGET_USER="${USER}"

if [[ -f "${ROOT_DIR}/bin/lib/common-logging.sh" ]]; then
    # shellcheck source=/dev/null
    source "${ROOT_DIR}/bin/lib/common-logging.sh"
else
    log() { printf "[cognitify-wsl] %s\n" "$*"; }
    error() { printf "[cognitify-wsl] ERROR: %s\n" "$*" >&2; }
fi

usage() {
    cat <<USAGE
Usage: bin/install-wsl.sh [options]

Install Cognitify for WSL (Windows Subsystem for Linux).

Copies bash.bashrc.d fragments to ~/.config/cognitify/bash.bashrc.d and
installs user dotfiles. No sudo is required. Cockpit, packages, and other
system services are not installed.

Options:
  --user <name>   Install for a specific user (default: ${TARGET_USER}).
  -h, --help      Show this help message.
USAGE
}

detect_wsl() {
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        return 0
    fi
    if [[ -r /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version; then
        return 0
    fi
    return 1
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --user)
                TARGET_USER="$2"
                shift 2
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
    if [[ ! -d "${CONFIG_SRC}" ]]; then
        error "Required directory missing: ${CONFIG_SRC}"
        exit 1
    fi
    if [[ ! -d "${HOME_FILES_SRC}" ]]; then
        error "Required directory missing: ${HOME_FILES_SRC}"
        exit 1
    fi
}

resolve_home() {
    local user_home
    user_home="$(getent passwd "${TARGET_USER}" 2>/dev/null | cut -d: -f6 || true)"
    if [[ -z "${user_home}" ]]; then
        if [[ "${TARGET_USER}" == "${USER}" ]]; then
            user_home="${HOME}"
        else
            error "Could not resolve home directory for user: ${TARGET_USER}"
            exit 1
        fi
    fi
    printf '%s\n' "${user_home}"
}

backup_if_exists() {
    local dest="$1"
    if [[ -e "${dest}" && ! -e "${dest}.orig" ]]; then
        cp -a "${dest}" "${dest}.orig"
        log "Backed up ${dest} to ${dest}.orig"
    fi
}

install_bash_configs() {
    local user_home="$1"
    local dest="${user_home}/.config/cognitify/bash.bashrc.d"
    backup_if_exists "${user_home}/.config/cognitify"
    mkdir -p "${dest}"
    cp -R "${CONFIG_SRC}/." "${dest}/"
    log "Installed bash configuration into ${dest}"
}

install_home_files() {
    local user_home="$1"
    local file base dest
    for file in "${HOME_FILES_SRC}"/*; do
        [[ -f "${file}" ]] || continue
        base="$(basename "${file}")"
        dest="${user_home}/.${base}"
        backup_if_exists "${dest}"
        install -m 0644 "${file}" "${dest}"
        log "Installed ${dest}"
    done
}

main() {
    parse_args "$@"
    assert_paths

    if ! detect_wsl; then
        log "Warning: WSL was not detected; continuing with user-local install anyway."
    fi

    local user_home
    user_home="$(resolve_home)"
    install_bash_configs "${user_home}"
    install_home_files "${user_home}"

    log "Done. Open a new interactive Bash session."
    log "Cockpit and package installation were skipped (not supported on WSL)."
}

main "$@"
