#!/usr/bin/env bash
# Common logging functions for Cognitify scripts
# (c) 2026 Ramon Brooker <rbrooker@aeo3.io>
#
# Usage:
#   source bin/lib/common-logging.sh
#
# Environment Variables:
#   LOG_PREFIX       - Prefix for log messages (default: "cognitify")
#   USE_SYSLOG       - Enable syslog logging: 0=disabled (default), 1=enabled
#   SYSLOG_FACILITY  - Syslog facility: user, daemon, local0-local7 (default: "user")
#   SYSLOG_TAG       - Syslog tag/identifier (default: value of LOG_PREFIX)
#   NO_COLOR         - Disable color output (set to any value)
#
# Functions:
#   log()      - Log info message to stdout
#   error()    - Log error message to stderr
#   warn()     - Log warning message to stderr
#   info()     - Log info message to stdout
#   log_timestamp() - Log message with timestamp
#
# Examples:
#   # Basic usage
#   source bin/lib/common-logging.sh
#   log "Installation started"
#   error "Failed to install package"
#
#   # With syslog enabled
#   USE_SYSLOG=1 source bin/lib/common-logging.sh
#   log "This will also go to syslog"
#
#   # Custom prefix
#   LOG_PREFIX="myapp" source bin/lib/common-logging.sh
#   log "Custom prefix message"
#
#   # Custom syslog facility
#   USE_SYSLOG=1 SYSLOG_FACILITY="daemon" source bin/lib/common-logging.sh
#   log "Message to daemon facility"

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

# Syslog configuration
# Set USE_SYSLOG=1 to enable syslog logging
USE_SYSLOG="${USE_SYSLOG:-0}"
# Syslog facility (user, daemon, local0-local7)
SYSLOG_FACILITY="${SYSLOG_FACILITY:-user}"
# Syslog tag (identifier for log entries)
SYSLOG_TAG="${SYSLOG_TAG:-${LOG_PREFIX}}"

# Function: _log_to_syslog
# Internal function to send message to syslog
# Parameters:
#   $1 - Priority (info, warning, err, debug)
#   $@ - Message to log
_log_to_syslog() {
    local priority="$1"
    shift
    local message="$*"
    
    if [[ "$USE_SYSLOG" == "1" ]] && command -v logger >/dev/null 2>&1; then
        logger -t "$SYSLOG_TAG" -p "${SYSLOG_FACILITY}.${priority}" "$message" 2>/dev/null || true
    fi
}

# Function: log
# Logs a message to stdout with optional prefix and colour
# Also sends to syslog if USE_SYSLOG=1
# Parameters:
#   $@ - Message to log
log() {
    local message="[${LOG_PREFIX}] $*"
    
    # Output to stdout
    if [[ -n "$GREEN" ]]; then
        printf "${GREEN}[${LOG_PREFIX}]${NC} %s\n" "$*"
    else
        printf "[${LOG_PREFIX}] %s\n" "$*"
    fi
    
    # Send to syslog
    _log_to_syslog "info" "$message"
}

# Function: error
# Logs an error message to stderr with prefix and colour
# Also sends to syslog if USE_SYSLOG=1
# Parameters:
#   $@ - Error message to log
error() {
    local message="[${LOG_PREFIX}] ERROR: $*"
    
    # Output to stderr
    if [[ -n "$RED" ]]; then
        printf "${RED}[${LOG_PREFIX}] ERROR:${NC} %s\n" "$*" >&2
    else
        printf "[${LOG_PREFIX}] ERROR: %s\n" "$*" >&2
    fi
    
    # Send to syslog
    _log_to_syslog "err" "$message"
}

# Function: warn
# Logs a warning message to stderr with prefix and colour
# Also sends to syslog if USE_SYSLOG=1
# Parameters:
#   $@ - Warning message to log
warn() {
    local message="[${LOG_PREFIX}] WARNING: $*"
    
    # Output to stderr
    if [[ -n "$YELLOW" ]]; then
        printf "${YELLOW}[${LOG_PREFIX}] WARNING:${NC} %s\n" "$*" >&2
    else
        printf "[${LOG_PREFIX}] WARNING: %s\n" "$*" >&2
    fi
    
    # Send to syslog
    _log_to_syslog "warning" "$message"
}

# Function: info
# Logs an info message to stdout with prefix and colour
# Also sends to syslog if USE_SYSLOG=1
# Parameters:
#   $@ - Info message to log
info() {
    local message="[${LOG_PREFIX}] INFO: $*"
    
    # Output to stdout
    if [[ -n "$BLUE" ]]; then
        printf "${BLUE}[${LOG_PREFIX}] INFO:${NC} %s\n" "$*"
    else
        printf "[${LOG_PREFIX}] INFO: %s\n" "$*"
    fi
    
    # Send to syslog
    _log_to_syslog "info" "$message"
}

# Function: log_timestamp
# Logs a message with timestamp (for scripts that need timestamps)
# Also sends to syslog if USE_SYSLOG=1
# Parameters:
#   $@ - Message to log
log_timestamp() {
    local timestamp
    timestamp=$(date "+[%Y-%m-%d %H:%M:%S]")
    local message="${timestamp} $*"
    
    # Output to stdout
    echo "$message"
    
    # Send to syslog
    _log_to_syslog "info" "$message"
}
