#!/bin/bash 

## (C) 2023
## Ramon Brooker <rbrooker@aeo3.io>

# Variables defined here are exported for use in other scripts
# shellcheck disable=SC2034  # Unused variables are exported for external use

source "${LIB_DIR}"/variables.sh


# Function: cockpit-setup
# Configures Cockpit to listen on a specific IP address and port.
# Parameters:
#   $1 - HTTPS port (default: 443)
#   $2 - IP address (default: ${FIRST_IP_ADDRESS})
cockpit-setup() {
    local HTTPS_PORT="${1:-443}"
    local COCKPIT_IP="${2:-${FIRST_IP_ADDRESS}}"
    
    if [[ -z "${COCKPIT_SYSTEM_PATH}" ]]; then
        echo "Error: COCKPIT_SYSTEM_PATH is not set" >&2
        return 1
    fi
    
    if [[ ! -d "${COCKPIT_SYSTEM_PATH}" ]]; then
        echo "Error: Cockpit system path does not exist: ${COCKPIT_SYSTEM_PATH}" >&2
        return 1
    fi
    
    # Check if header file exists (if referenced)
    if [[ -n "${header}" ]] && [[ ! -f "${header}" ]]; then
        echo "Warning: Header file not found: ${header}" >&2
    fi
    
    cat > "${COCKPIT_SYSTEM_PATH}"/listen.conf <<EOF

$(cat "${header:-/dev/null}" 2>/dev/null || true)

[Socket]
ListenStream=
ListenStream=${COCKPIT_IP}:${HTTPS_PORT}

FreeBind=yes

EOF
    
    if [[ $? -eq 0 ]]; then
        echo "Cockpit configuration updated successfully"
    else
        echo "Error: Failed to write Cockpit configuration" >&2
        return 1
    fi
}

