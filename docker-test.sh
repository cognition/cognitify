#!/usr/bin/env bash
# Helper script to build and test Cognitify Docker images
# (c) 2025 Ramon Brooker <rbrooker@aeo3.io>

set -e

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Available distributions
DISTROS=("ubuntu" "debian" "fedora" "centos" "rocky" "opensuse")

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [DISTRO...]

Build and test Cognitify Docker images for various distributions.

Options:
  -b, --build-only      Build images only (don't run containers)
  -r, --run-only        Run containers only (assume images exist)
  -c, --clean           Remove containers and images after testing
  -h, --help            Show this help message

Distributions:
  ${DISTROS[*]}

If no distributions are specified, all will be built/tested.

Examples:
  $0 ubuntu                    # Build and test Ubuntu
  $0 ubuntu debian fedora     # Build and test multiple distros
  $0 --build-only             # Build all images
  $0 --run-only ubuntu         # Run Ubuntu container (assumes image exists)
EOF
}

log() {
    printf "${GREEN}[docker-test]${NC} %s\n" "$*"
}

error() {
    printf "${RED}[docker-test] ERROR:${NC} %s\n" "$*" >&2
}

warn() {
    printf "${YELLOW}[docker-test] WARNING:${NC} %s\n" "$*" >&2
}

info() {
    printf "${BLUE}[docker-test] INFO:${NC} %s\n" "$*"
}

build_image() {
    local distro="$1"
    local dockerfile="Dockerfile.${distro}"
    
    if [[ ! -f "$dockerfile" ]]; then
        error "Dockerfile not found: $dockerfile"
        return 1
    fi
    
    log "Building image for ${distro}..."
    docker build -f "$dockerfile" -t cognitify-test:${distro} . || {
        error "Failed to build ${distro} image"
        return 1
    }
    
    info "Successfully built cognitify-test:${distro}"
}

run_container() {
    local distro="$1"
    local image="cognitify-test:${distro}"
    local container="cognitify-test-${distro}"
    
    # Check if image exists
    if ! docker image inspect "$image" >/dev/null 2>&1; then
        error "Image not found: $image"
        error "Build it first with: $0 --build-only ${distro}"
        return 1
    fi
    
    # Remove existing container if it exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
        log "Removing existing container: ${container}"
        docker rm -f "${container}" >/dev/null 2>&1 || true
    fi
    
    log "Starting container for ${distro}..."
    info "Container name: ${container}"
    info "User: cognition"
    info "To exit, type 'exit' or press Ctrl+D"
    echo ""
    
    docker run -it --name "${container}" "${image}" || {
        error "Container exited with error"
        return 1
    }
}

clean_image() {
    local distro="$1"
    local image="cognitify-test:${distro}"
    local container="cognitify-test-${distro}"
    
    log "Cleaning up ${distro}..."
    
    # Remove container
    if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
        docker rm -f "${container}" >/dev/null 2>&1 || true
    fi
    
    # Remove image
    if docker image inspect "$image" >/dev/null 2>&1; then
        docker rmi "${image}" >/dev/null 2>&1 || true
    fi
}

# Parse arguments
BUILD_ONLY=false
RUN_ONLY=false
CLEAN=false
SELECTED_DISTROS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        -r|--run-only)
            RUN_ONLY=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [[ " ${DISTROS[*]} " =~ " ${1} " ]]; then
                SELECTED_DISTROS+=("$1")
            else
                error "Unknown distribution: $1"
                error "Available: ${DISTROS[*]}"
                exit 1
            fi
            shift
            ;;
    esac
done

# Use all distros if none specified
if [[ ${#SELECTED_DISTROS[@]} -eq 0 ]]; then
    SELECTED_DISTROS=("${DISTROS[@]}")
fi

# Validate options
if [[ "$BUILD_ONLY" = true ]] && [[ "$RUN_ONLY" = true ]]; then
    error "Cannot use --build-only and --run-only together"
    exit 1
fi

# Main execution
log "Starting Docker testing for distributions: ${SELECTED_DISTROS[*]}"

for distro in "${SELECTED_DISTROS[@]}"; do
    echo ""
    info "Processing ${distro}..."
    
    if [[ "$BUILD_ONLY" = false ]]; then
        if ! build_image "$distro"; then
            warn "Skipping ${distro} due to build failure"
            continue
        fi
    fi
    
    if [[ "$RUN_ONLY" = false ]] && [[ "$BUILD_ONLY" = false ]]; then
        run_container "$distro"
    elif [[ "$RUN_ONLY" = true ]]; then
        run_container "$distro"
    fi
    
    if [[ "$CLEAN" = true ]]; then
        clean_image "$distro"
    fi
done

log "Docker testing complete!"

