## (c) 2026
## Ramon Brooker <rbrooker@aeo3.io>
## Cognitify system-wide profile configuration

# Bash-only: bashrc_file uses bash syntax. /etc/profile may source this via /bin/sh
# (e.g. su without -, dash), so skip unless the current shell is bash.

if [ -z "${BASH_VERSION:-}" ]; then
    return 0 2>/dev/null || true
fi

BASE_PATH="/etc/bash.bashrc.d"

if [ -f "${BASE_PATH}/bashrc_file" ]; then
    # shellcheck source=/dev/null
    . "${BASE_PATH}/bashrc_file"
fi
