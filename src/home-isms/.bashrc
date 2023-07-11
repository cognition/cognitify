#!/bin/bash

export HOME_BASHRC_VERSION=1

## (C) 2023
## Ramon Brooker <rbrooker@aeo3.io>

# shellcheck source=/dev/null
if [[ -f /etc/bash.bashrc.d/bashrc ]]; then
    source /etc/bash.bashrc.d/bashrc
fi
