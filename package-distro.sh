#!/usr/bin/env bash
# Package Cognitify for a specific distribution
# (c) 2025 Ramon Brooker <rbrooker@aeo3.io>

set -e

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Colour

# Distribution to package manager mapping
declare -A DISTRO_PKG_MANAGER=(
    ["ubuntu"]="apt-get"
    ["debian"]="apt-get"
    ["fedora"]="dnf"
    ["centos"]="yum"
    ["rocky"]="dnf"
    ["rhel"]="yum"
    ["almalinux"]="dnf"
    ["mariner"]="dnf"
    ["azurelinux"]="dnf"
    ["opensuse"]="zypper"
    ["sles"]="zypper"
)

# Package manager to package file mapping
declare -A PKG_MANAGER_FILE=(
    ["apt-get"]="PACKAGES_APT"
    ["yum"]="PACKAGES_YUM"
    ["dnf"]="PACKAGES_YUM"
    ["zypper"]="PACKAGES_ZYPPER"
)

log() {
    printf "${GREEN}[package]${NC} %s\n" "$*"
}

error() {
    printf "${RED}[package] ERROR:${NC} %s\n" "$*" >&2
}

warn() {
    printf "${YELLOW}[package] WARNING:${NC} %s\n" "$*" >&2
}

# Get version from version file
get_version() {
    if [[ -f "version" ]]; then
        cat version | tr -d '\n' | tr -d ' '
    else
        echo "0.0.1"
    fi
}

# Validate distro
validate_distro() {
    local distro="$1"
    if [[ -z "${DISTRO_PKG_MANAGER[$distro]:-}" ]]; then
        error "Unsupported distribution: $distro"
        error "Supported distributions: ${!DISTRO_PKG_MANAGER[*]}"
        return 1
    fi
    return 0
}

# Create package
create_package() {
    local distro="$1"
    local version
    version=$(get_version)
    local pkg_manager="${DISTRO_PKG_MANAGER[$distro]}"
    local pkg_file="${PKG_MANAGER_FILE[$pkg_manager]}"
    
    log "Packaging Cognitify for $distro (version $version)"
    log "Package manager: $pkg_manager"
    
    # Create releases directory
    local releases_dir="releases"
    mkdir -p "$releases_dir"
    
    # Create temporary directory for packaging
    local temp_dir
    temp_dir=$(mktemp -d)
    local package_name="cognitify-${distro}-${version}"
    local package_dir="${temp_dir}/${package_name}"
    
    log "Creating package structure in temporary directory..."
    mkdir -p "$package_dir"
    
    # Copy source directories (excluding packages, which we'll handle separately)
    log "Copying source files..."
    # Copy src directory but exclude packages
    mkdir -p "$package_dir/src"
    for item in src/*; do
        if [[ "$(basename "$item")" != "packages" ]]; then
            cp -r "$item" "$package_dir/src/"
        fi
    done
    
    # Copy build system files
    log "Copying build system files..."
    cp configure "$package_dir/"
    cp Makefile "$package_dir/"
    cp post-install.sh "$package_dir/"
    chmod +x "$package_dir/configure"
    chmod +x "$package_dir/post-install.sh"
    
    # Copy documentation
    log "Copying documentation..."
    if [[ -d "docs" ]]; then
        cp -r docs/ "$package_dir/"
    fi
    if [[ -d "man" ]]; then
        cp -r man/ "$package_dir/"
    fi
    if [[ -f "README.md" ]]; then
        cp README.md "$package_dir/"
    fi
    if [[ -f "BUILD.md" ]]; then
        cp BUILD.md "$package_dir/"
    fi
    if [[ -f "DOCKER.md" ]]; then
        cp DOCKER.md "$package_dir/"
    fi
    if [[ -f "changelog" ]]; then
        cp changelog "$package_dir/"
    fi
    
    # Copy version file
    cp version "$package_dir/"
    
    # Copy old installer script (for backward compatibility)
    if [[ -d "bin" ]]; then
        mkdir -p "$package_dir/bin"
        if [[ -f "bin/install.sh" ]]; then
            cp bin/install.sh "$package_dir/bin/"
            chmod +x "$package_dir/bin/install.sh"
        fi
        if [[ -d "bin/lib" ]]; then
            cp -r bin/lib "$package_dir/bin/"
        fi
    fi
    
    # Create distro-specific package list (only include relevant package files)
    log "Creating distro-specific package lists..."
    mkdir -p "$package_dir/src/packages"
    
    # Always include GENERAL
    if [[ -f "src/packages/GENERAL" ]]; then
        cp "src/packages/GENERAL" "$package_dir/src/packages/"
    fi
    
    # Include GENERAL_GUI
    if [[ -f "src/packages/GENERAL_GUI" ]]; then
        cp "src/packages/GENERAL_GUI" "$package_dir/src/packages/"
    fi
    
    # Include distro-specific package file
    if [[ -n "$pkg_file" ]] && [[ -f "src/packages/$pkg_file" ]]; then
        cp "src/packages/$pkg_file" "$package_dir/src/packages/"
        log "Included package file: $pkg_file"
    else
        # Create empty file if it doesn't exist
        touch "$package_dir/src/packages/$pkg_file"
        warn "Package file $pkg_file not found, created empty file"
    fi
    
    # Include distro-specific files
    if [[ -d "src/distro-files" ]]; then
        mkdir -p "$package_dir/src/distro-files"
        # Copy all distro files (they're small)
        cp -r src/distro-files/* "$package_dir/src/distro-files/" 2>/dev/null || true
    fi
    
    # Create .gitignore for the package
    cat > "$package_dir/.gitignore" <<EOF
# Generated package - do not commit
config.mk
*.orig
EOF
    
    # Create README for the package
    cat > "$package_dir/README-PACKAGE.md" <<EOF
# Cognitify Package for ${distro^}

This is a distribution-specific package of Cognitify version ${version} for ${distro^}.

## Installation

\`\`\`bash
./configure
make
sudo make install
\`\`\`

See BUILD.md for detailed installation instructions.

## Package Contents

- Source files (bash.bashrc.d, home-files, completions, etc.)
- Build system (configure, Makefile, post-install.sh)
- Documentation
- Distribution-specific package lists
- Version: ${version}

## Distribution Information

- Distribution: ${distro^}
- Package Manager: ${pkg_manager}
- Package File: ${pkg_file}

Generated: $(date +"%Y-%m-%d %H:%M:%S")
EOF
    
    # Create the tar.gz archive
    log "Creating archive..."
    local archive_name="${package_name}.tar.gz"
    local archive_path="${releases_dir}/${archive_name}"
    
    # Use absolute path for archive
    local abs_archive_path
    abs_archive_path=$(cd "$releases_dir" && pwd)/${archive_name}
    
    cd "$temp_dir"
    tar -czf "$abs_archive_path" "$package_name"
    cd - > /dev/null
    
    # Get file size
    local file_size
    file_size=$(du -h "$archive_path" | cut -f1)
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log "Package created successfully!"
    log "Archive: $archive_path"
    log "Size: $file_size"
    log ""
    log "To install this package:"
    log "  tar -xzf $archive_path"
    log "  cd $package_name"
    log "  ./configure"
    log "  make"
    log "  sudo make install"
}

# Main
main() {
    local distro="$1"
    
    if [[ -z "$distro" ]]; then
        error "Distribution name required"
        echo "Usage: $0 <distro>"
        echo "Supported distributions: ${!DISTRO_PKG_MANAGER[*]}"
        exit 1
    fi
    
    # Normalize distro name to lowercase
    distro=$(echo "$distro" | tr '[:upper:]' '[:lower:]')
    
    if ! validate_distro "$distro"; then
        exit 1
    fi
    
    create_package "$distro"
}

main "$@"

