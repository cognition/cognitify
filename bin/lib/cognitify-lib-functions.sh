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


function add-cognitify-grp() {
    groupadd cognitify 
    usermod -aG cognitify "${SUDO_USER}"
} 

function make-dirs() {
    for dir in "${COGNITIFY_DIRS[@]}"
    do 
        if [[ ! -d "${dir}" ]]; then
            printf 'creating directoy: %s' "${dir}"
            mkdir -p "${dir}" 
        else
            printf 'skipping existing directory:  %s ' "${dir}"
        fi
    done
}

function cognitify-dirs() {
    for dir in "${COGNITIFY_DIRS[@]}"
    do 
        printf '%s' "${dir}"
        chgrp -R cognitify "${dir}"
        chmod -R g+w "${dir}"
    done
}

function copy-libs() {

    ls "${SRC_DIR}"/bashism-lib/* "${COGNITIFY_BASE}/lib"/
}

function copy-bashisms() {
    ls "${SRC_DIR}"/bashisms/* "${COGNITIFY_BASE}"/
}

function copy-completions() {
    ls "${SRC_DIR}"/completions/* /etc/bash_completions.d/
}

function copy-home-isms() {
    ls "${SRC_DIR}/home-isms/".* "${HOME}"/
    ls "${SRC_DIR}/home-isms/".* "/home/${SUDO_USER}"/
}

function fix-permissions() {
    echo "Make sure ${SUDO_USER} owns their own home files"
    chmod -R "${SUDO_USER}": "/home/${SUDO_USER}"
    cognitify-dirs
}