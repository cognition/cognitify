## (c) 2026
## Ramon Brooker <rbrooker@aeo3.io>
## Cognitify system-wide profile configuration

# Source cognitify bashrc_file for login shells (including SSH)
# This ensures cognitify configuration is available even for non-interactive login shells
BASE_PATH="/etc/bash.bashrc.d"

if [[ -f "${BASE_PATH}/bashrc_file" ]]; then
    # shellcheck source=/dev/null
    source "${BASE_PATH}/bashrc_file"
fi

