# dirsync

Robust rsync wrapper for safe, resumable file transfers.

## Synopsis

```bash
dirsync [OPTIONS] <source> <destination>
dirsync --source <src> --dest <dst> [OPTIONS]
```

## Description

A wrapper around rsync that provides:
- Automatic destination directory creation
- Include/exclude rules from config file
- Dry run mode
- Logging with timestamps
- Safe file transfers

## Options

- `-s, --source <dir>` - Source directory
- `-d, --dest <dir>` - Destination directory (created if missing)
- `-l, --log <file>` - Log output to file (timestamped)
- `-r, --rules <file>` - Path to include/exclude rule file
- `-n, --dry-run` - Simulate only (no changes)
- `-k, --keep-source` - Do NOT delete source files after sync
- `-h, --help` - Show help message

## Examples

```bash
# Basic sync
dirsync /source/data /backup/data

# Dry run
dirsync --source /source --dest /backup --dry-run

# With logging
dirsync /source /backup --log /var/log/sync.log

# With rules file
dirsync --source /data --dest /backup --rules /etc/sync-rules.conf
```

## Rules File Format

```ini
[include]
*.txt
*.log

[exclude]
*.tmp
*.bak
```

## Features

- Resumable transfers
- Progress display
- ACL and extended attributes preservation
- Partial file support
- Human-readable output

