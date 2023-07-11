#!/bin/bash 

## (C) 2023
## Ramon Brooker <rbrooker@aeo3.io>
#shellcheck disable=SC2034

function get-root-directory() {
    PARENT_DIR=$(pwd | sed -E 's/(.+)\/cognitify/\1/ ')
    ROOT_DIR="${PARENT_DIR}/cognitify"
    LIB_DIR="${ROOT_DIR}/bin/lib"
    BIN_DIR="${ROOT_DIR}/bin"
    SRC_DIR="${ROOT_DIR}/src"
}
get-root-directory 

source "${LIB_DIR}"/cognitify-lib-functions.sh 

# check-pwd 
if [[ ${USER} != "root" ]]; then 
    echo "you must me root or use sudo" 
    # exit 1
else 
    echo "you are installing for $SUDO_USER using sudo access" 
fi
echo ""
echo ""

if [[ "${ACTION}" == "new" ]]; then 
# Create Group
    add-cognitify-grp
    make-dirs
    cognitify-dirs 
fi 

copy-libs
copy-bashisms
copy-completions
copy-home-isms
fix-permissions
cognitify-dirs
append-etc-bashrc

## add prompt for action
make-user-passwordless 





echo "${CURRENT_VERSION}" > "${VERSION_FILE}"

if [ "${ACTION}" == "new" ]; then 
    echo "Now logout and back in again to reload the group permisions"
fi 





echo "enjoy!" 