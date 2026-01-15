#!/bin/bash 

## (C) 2026
## Ramon Brooker <rbrooker@aeo3.io>

# Variables for Cognitify and Computed Variables

# Variables defined here are exported for use in other scripts
# shellcheck disable=SC2034  # Unused variables are exported for external use

CURRENT_VERSION="$(cat "${ROOT_DIR}"/version)"

VERSION_FILE="/etc/bash.bashrc.d/.cognitify-version"

if [[ -f "${VERSION_FILE}" ]] && [[ -r "${VERSION_FILE}" ]]; then 
    INSTALLED_VERSION=$(cat "${VERSION_FILE}")
else
    INSTALLED_VERSION="none"
fi

if [ "${INSTALLED_VERSION}" = "none" ]; then 
    ACTION="new"
else 
    if [[ "${CURRENT_VERSION}" = "${INSTALLED_VERSION}" ]]; then 
        ACTION="no action"
    elif [[ "$(printf '%s\n' "${CURRENT_VERSION}" "${INSTALLED_VERSION}" | sort -V | head -n1)" != "${CURRENT_VERSION}" ]]; then 
        # Installed version is newer than current
        ACTION="installed is newer"
    else   
        ACTION="update"
    fi 
fi 
COGNITIFY_BASE="/etc/bash.bashrc.d"
declare -a COGNITIFY_DIRS
COGNITIFY_DIRS=( "${COGNITIFY_BASE}" "${COGNITIFY_BASE}/lib" )



cat > GENERAL <<EOF 
bash-completion git ShellCheck cockpit cockpit-bridge sqlite3-devel sqlite3 tree unzip zip expect
curl wget hwinfo jq fq dos2unix vim neovim openssh openssl pwgen rsync syntax-highlighting xfsdump xfsprogs 
EOF

cat > GENERAL_GUI <<EOF 
yakuake konsole kate kdeconnect krusader 
dolphin kwrite gparted 
EOF


cat > PACKAGES_APT <<EOF 




EOF


cat > PACKAGES_YUM <<EOF 




EOF

cat > PACKAGES_ZYPPER <<EOF 

cockpit-system 


EOF








