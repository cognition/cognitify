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
source "${LIB_DIR}"/cognitify-add-ons.sh 


## [TODO]
## configure cockpit
## install vscode, chrome, opera 
## template .ssh/config 