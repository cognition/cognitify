# create-repo.sh

Scaffolds a new repository with standard directory structure and files.

## Synopsis

```bash
create-repo.sh <repo-name> --name "Your Name" --email "you@example.com" [--lang python|bash|ruby]
```

## Description

Creates a new repository with:
- Standard directory structure (src, docs, test, logs, private, tmp, scratch)
- Documentation templates
- .gitignore configuration
- Language-specific scaffolding (optional)
- Git initialization

## Options

- `--name "Name"` - Author name (required, or set AUTHOR_NAME env var)
- `--email "email"` - Author email (required, or set AUTHOR_EMAIL env var)
- `--lang <language>` - Language scaffold (python, bash, or ruby)

## Examples

```bash
# Create Python project
create-repo.sh myproject --name "John Doe" --email "john@example.com" --lang python

# Create bash project
create-repo.sh myscript --name "Jane Smith" --email "jane@example.com" --lang bash

# Using environment variables
export AUTHOR_NAME="John Doe"
export AUTHOR_EMAIL="john@example.com"
create-repo.sh myproject --lang python
```

## Directory Structure

```
repo-name/
├── src/
├── docs/
│   ├── index.md
│   └── usage.md
├── test/
├── logs/
├── private/
├── tmp/
├── scratch/
├── README.md
└── .gitignore
```

Language-specific files are added based on `--lang` option.

