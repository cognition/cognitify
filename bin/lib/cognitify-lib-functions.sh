#!/bin/bash 

## (C) 2023
## Ramon Brooker <rbrooker@aeo3.io>
#shellcheck disable=SC2034

source "${LIB_DIR}"/variables.sh


function cockpit-setup() {

HTTPS_PORT="${1:-443}"
COCKPIT_IP="${2:-${FIRST_IP_ADDRESS}}"

cat > "${COCKPIT_SYSTEM_PATH}"/listen.conf <<EOF

$(cat header)

[Socket]
ListenStream=
ListenStream=${COCKPIT_IP}:${HTTPS_PORT}

FreeBind=yes

EOF
}

