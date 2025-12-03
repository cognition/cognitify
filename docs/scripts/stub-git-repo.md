# stub-git-repo.sh

Creates a git repository structure with documentation and scaffolding.

## Synopsis

```bash
stub-git-repo.sh <repo-name> --name "Your Name" --email "you@example.com" [--lang python|bash|ruby]
```

## Description

Similar to `create-repo.sh`, but with additional git-specific features:
- Git initialization with 'main' branch
- Initial commit with scaffolded files
- Language-specific templates

## Options

- `--name "Name"` - Author name (required, or set AUTHOR_NAME env var)
- `--email "email"` - Author email (required, or set AUTHOR_EMAIL env var)
- `--lang <language>` - Language scaffold (python, bash, or ruby)

## Examples

```bash
# Create Python git repo
stub-git-repo.sh myproject --name "John Doe" --email "john@example.com" --lang python

# Create bash git repo
stub-git-repo.sh myscript --name "Jane Smith" --email "jane@example.com" --lang bash
```

## Differences from create-repo.sh

- Automatically initializes git repository
- Creates initial commit
- Uses 'main' as default branch name
- Includes commit message with language info

