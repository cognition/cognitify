#!/bin/bash

export HOME_BASHRC_VERSION=2

## (C) 2024
## Ramon Brooker <rbrooker@aeo3.io>

if [[ -f ~/.over-write ]]; then 
	source ~/.over-write
fi 


# shellcheck source=/dev/null
if [[ -f /etc/bash.bashrc.d/bashrc ]]; then
    source /etc/bash.bashrc.d/bashrc
fi


# shellcheck source=/dev/null
if [[ -f /etc/bash.bashrc.d/last-line ]]; then
    source /etc/bash.bashrc.d/last-line
fi

