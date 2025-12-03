# Cognitify Documentation

Welcome to the Cognitify documentation. This catalog provides an overview of all helper functions and scripts included with Cognitify.

## Table of Contents

- [Helper Functions](#helper-functions)
  - [Cognitify Helpers](helpers/cognitify-helpers.md)
  - [Admin Helpers](helpers/admin-helpers.md)
  - [Container Helpers](helpers/container-helpers.md)
  - [Directory Helpers](helpers/directory-helpers.md)
  - [File Search Helpers](helpers/file-search-helpers.md)
  - [Python Helpers](helpers/python-helpers.md)
- [Utility Scripts](#utility-scripts)
  - [check-chars](scripts/check-chars.md)
  - [create-repo.sh](scripts/create-repo.md)
  - [dirsync](scripts/dirsync.md)
  - [mkfolders](scripts/mkfolders.md)
  - [opera-custom](scripts/opera-custom.md)
  - [stub-git-repo.sh](scripts/stub-git-repo.md)

## Quick Reference

### System Information
- `ddistro` - Detect Linux distribution information
- `group-check` - Check if user is in a group
- `app-is-there` - Check if application exists in PATH
- `app-values` - Get application availability status

### File Management
- `stub-script` - Create shell script template
- `note-addition` - Append timestamped notes
- `search-files` - Search files with filters
- `list-empty-dirs` - List empty directories
- `del-empty-dirs` - Delete empty directories

### Container Management
- `docker-list-types` - List Docker images by pattern
- `docker-cleanup-old-builds` - Clean Docker dangling images
- `docker-cleanup-containers` - Remove exited Docker containers
- `shell-into-docker` - Enter Docker container
- `podman-cleanup-old-builds` - Clean Podman dangling images
- `podman-cleanup-containers` - Remove exited Podman containers
- `pod-shell-into` - Enter Podman container

### Development
- `setpyenv` - Create Python 3.12 virtual environment
- `create-repo.sh` - Scaffold new repository
- `stub-git-repo.sh` - Create git repository structure

### System Administration
- `update-hostname` - Update system hostname and domain
- `get-system-ips` - Display all system IP addresses
- `add-environment-tag` - Add system environment variables
- `user-exists` - Check if user exists

### Network
- `find-latency` - Measure network latency to addresses

### Utilities
- `check-chars` - Character counter utility
- `dirsync` - Robust rsync wrapper
- `mkfolders` - Create directories from file list
- `opera-custom` - Create Opera browser profile shortcuts

## Getting Help

For detailed information about any function or script, see the individual documentation pages linked above, or use the man page:

```bash
man cognitify
```

## See Also

- [Installation Guide](../BUILD.md)
- [Docker Testing](../DOCKER.md)
- [Main README](../README.md)

