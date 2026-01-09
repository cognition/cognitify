# Docker Testing Guide

This guide explains how to test Cognitify installations using Docker containers for various Linux distributions.

## Quick Start

```bash
# Build and test Ubuntu
docker build -f Dockerfile.ubuntu -t cognitify-test:ubuntu .
docker run -it --name cognitify-test-ubuntu cognitify-test:ubuntu

# Or use the helper script
./docker-test.sh ubuntu
```

## Available Distributions

The following Dockerfiles are available:

- **Dockerfile.ubuntu** - Ubuntu (latest)
- **Dockerfile.debian** - Debian (latest)
- **Dockerfile.fedora** - Fedora (latest)
- **Dockerfile.centos** - CentOS (latest)
- **Dockerfile.rocky** - Rocky Linux (latest)
- **Dockerfile.almalinux** - AlmaLinux (latest)
- **Dockerfile.azurelinux** - Azure Linux / CBL-Mariner (latest)
- **Dockerfile.opensuse** - openSUSE Leap (latest)

## Manual Build and Test

### Build an Image

```bash
docker build -f Dockerfile.ubuntu -t cognitify-test:ubuntu .
```

### Run a Container

```bash
docker run -it --name cognitify-test-ubuntu cognitify-test:ubuntu
```

This will:
1. Start the container
2. Log in as the `cognition` user
3. Drop into a bash shell with Cognitify configured
4. Allow you to test helper functions and configurations

### Exit the Container

Type `exit` or press `Ctrl+D` to exit the container.

### Remove Container After Testing

```bash
docker rm cognitify-test-ubuntu
```

### Remove Image

```bash
docker rmi cognitify-test:ubuntu
```

## Using the Helper Script

The `docker-test.sh` script automates building and testing:

### Build All Images

```bash
./docker-test.sh --build-only
```

### Test Specific Distributions

```bash
# Test Ubuntu only
./docker-test.sh ubuntu

# Test multiple distributions
./docker-test.sh ubuntu debian fedora
```

### Build and Test All Distributions

```bash
./docker-test.sh
```

### Run Existing Containers

If you've already built images:

```bash
./docker-test.sh --run-only ubuntu
```

### Clean Up After Testing

```bash
# Build, test, and clean up
./docker-test.sh --clean ubuntu

# Clean up all
./docker-test.sh --clean
```

## Testing Cognitify Features

Once inside a container, you can test:

### Helper Functions

```bash
# Test distribution detection
ddistro
ddistro 0  # distro name
ddistro 1  # version
ddistro 2  # distro family
ddistro 3  # package manager

# Test group check
group-check sudo

# Test app detection
app-is-there vim
app-values git

# Test latency
find-latency 8.8.8.8 1.1.1.1

# Test Python environment setup
setpyenv myproject
```

### Docker/Podman Functions

```bash
# List Docker images
docker-list-types '<none>'

# Cleanup Docker
docker-cleanup-old-builds
docker-cleanup-containers
```

### Directory Functions

```bash
# List empty directories
list-empty-dirs

# Delete empty directories
del-empty-dirs
```

### File Search

```bash
# Search for files
search_files -d /etc -t conf -r

# Search and execute
search_files -d /tmp -t sh -e "echo {}"
```

## Container Details

Each container:

- **User**: `cognition` (with sudo privileges)
- **Working Directory**: `/home/cognition`
- **Cognitify Installation**: `/etc/bash.bashrc.d/`
- **User Dotfiles**: `~/.bashrc`, `~/.vimrc`, etc.
- **Binaries**: `/usr/local/bin/`

## Troubleshooting

### "Permission denied" during build

Make sure the `configure` script is executable:
```bash
chmod +x configure
```

### Container exits immediately

Check the Dockerfile build logs:
```bash
docker build -f Dockerfile.ubuntu -t cognitify-test:ubuntu . 2>&1 | tail -20
```

### Cannot find package manager

The Dockerfiles use `--skip-packages` to avoid package installation issues. If you want to test package installation, modify the Dockerfile to remove `--skip-packages` and ensure the base image has the package manager configured.

### Test package installation

To test the full installation including packages, modify the Dockerfile:

```dockerfile
# Change this line:
RUN ./configure --user=${USERNAME} --skip-packages && \

# To this:
RUN ./configure --user=${USERNAME} && \
```

Note: This requires network access and may take longer.

## Continuous Integration

You can use these Dockerfiles in CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Test Ubuntu
  run: |
    docker build -f Dockerfile.ubuntu -t cognitify-test:ubuntu .
    docker run --rm cognitify-test:ubuntu bash -c "ddistro && echo 'Test passed'"
```

## Notes

- Containers are built with `--skip-packages` by default to speed up builds
- The `cognition` user has sudo privileges for testing
- All containers drop into an interactive bash shell
- Source code is copied into `/opt/cognitify` in the container

