#!/usr/bin/env bash
# Common logging functions for Cognitify scripts
# (c) 2026 Ramon Brooker <rbrooker@aeo3.io>

# Colours (will be empty if output is not a terminal or NO_COLOR is set)
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Colour
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Logging prefix (can be overridden by scripts)
LOG_PREFIX="${LOG_PREFIX:-cognitify}"

# Function: log
# Logs a message to stdout with optional prefix and colour
# Parameters:
#   $@ - Message to log
log() {
    if [[ -n "$GREEN" ]]; then
        printf "${GREEN}[${LOG_PREFIX}]${NC} %s\n" "$*"
    else
        printf "[${LOG_PREFIX}] %s\n" "$*"
    fi
}

# Function: error
# Logs an error message to stderr with prefix and colour
# Parameters:
#   $@ - Error message to log
error() {
    if [[ -n "$RED" ]]; then
        printf "${RED}[${LOG_PREFIX}] ERROR:${NC} %s\n" "$*" >&2
    else
        printf "[${LOG_PREFIX}] ERROR: %s\n" "$*" >&2
    fi
}

# Function: warn
# Logs a warning message to stderr with prefix and colour
# Parameters:
#   $@ - Warning message to log
warn() {
    if [[ -n "$YELLOW" ]]; then
        printf "${YELLOW}[${LOG_PREFIX}] WARNING:${NC} %s\n" "$*" >&2
    else
        printf "[${LOG_PREFIX}] WARNING: %s\n" "$*" >&2
    fi
}

# Function: info
# Logs an info message to stdout with prefix and colour
# Parameters:
#   $@ - Info message to log
info() {
    if [[ -n "$BLUE" ]]; then
        printf "${BLUE}[${LOG_PREFIX}] INFO:${NC} %s\n" "$*"
    else
        printf "[${LOG_PREFIX}] INFO: %s\n" "$*"
    fi
}

# Function: log_timestamp
# Logs a message with timestamp (for scripts that need timestamps)
# Parameters:
#   $@ - Message to log
log_timestamp() {
    local timestamp
    timestamp=$(date "+[%Y-%m-%d %H:%M:%S]")
    echo "${timestamp} $*"
}
