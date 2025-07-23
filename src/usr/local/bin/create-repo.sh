#!/bin/bash

# Usage:
#   ./create-repo.sh <repo-name> --name "Your Name" --email "you@example.com" [--lang python|bash|ruby]
#   or set AUTHOR_NAME and AUTHOR_EMAIL as environment variables

set -e

REPO_NAME=""
CLI_NAME=""
CLI_EMAIL=""
LANG="python"  # default
TODAY=$(date +"%Y-%m-%d")

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --lang)
      LANG="$2"
      shift 2
      ;;
    --name)
      CLI_NAME="$2"
      shift 2
      ;;
    --email)
      CLI_EMAIL="$2"
      shift 2
      ;;
    *)
      if [[ -z "$REPO_NAME" ]]; then
        REPO_NAME="$1"
        shift
      else
        shift
      fi
      ;;
  esac
done

AUTHOR_NAME="${CLI_NAME:-$AUTHOR_NAME}"
AUTHOR_EMAIL="${CLI_EMAIL:-$AUTHOR_EMAIL}"

if [[ -z "$REPO_NAME" || -z "$AUTHOR_NAME" || -z "$AUTHOR_EMAIL" ]]; then
  echo "Usage: $0 <repo-name> --name \"Your Name\" --email \"you@example.com\" [--lang python|bash|ruby]"
  echo "Or set AUTHOR_NAME and AUTHOR_EMAIL as environment variables."
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "❌ Git is not installed or not in your PATH."
  exit 1
fi

mkdir -p "$REPO_NAME"/{src,docs,tests,logs,private,tmp,scratch}
cd "$REPO_NAME"

echo "SHOULD_BE_EMPTY_IN_SOURCE_CONTROL" > private/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
echo "SHOULD_BE_EMPTY_IN_SOURCE_CONTROL" > tmp/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
touch logs/.gitkeep

cat > private/dummy-creds.md <<EOF
# Credential Format Documentation

Author: $AUTHOR_NAME <$AUTHOR_EMAIL>  
Date: $TODAY

Use this file to document the format the credentials should take,
but **do not include** the actual credentials here.
EOF

cat > docs/index.md <<EOF
# Documentation Index

Author: $AUTHOR_NAME <$AUTHOR_EMAIL>  
Date: $TODAY

- [Usage](usage.md)
EOF

cat > docs/usage.md <<EOF
# Usage Instructions

Coming soon.

[Back to Index](index.md)
EOF

cat > README.md <<EOF
# $REPO_NAME

Author: $AUTHOR_NAME <$AUTHOR_EMAIL>  
Created: $TODAY

Project description goes here.

📚 [Documentation](docs/index.md)
EOF

cat > .gitignore <<'EOF'
*~
~*
*swp
*log

## Private and Temporary files
private/*
!private/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
!private/dummy-creds.md

tmp/*
!tmp/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL

logs/*
!logs/.gitkeep

scratch/
EOF

TRACK_FILES=(README.md .gitignore docs/index.md docs/usage.md logs/.gitkeep private/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL private/dummy-creds.md tmp/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL)

case "$LANG" in
  python)
    cat > __init__.py <<EOF
# Init for $REPO_NAME package
EOF

    cat > main.py <<EOF
def main():
    print("Hello from $REPO_NAME")

if __name__ == "__main__":
    main()
EOF

    cat > requirements.txt <<EOF
# Python dependencies
EOF

    cat > pyproject.toml <<EOF
[project]
name = "$REPO_NAME"
version = "0.1.0"
description = "A Python project scaffold"
authors = ["$AUTHOR_NAME <$AUTHOR_EMAIL>"]
EOF

    cat > tests/test_main.py <<EOF
def test_main_output(capsys):
    from main import main
    main()
    captured = capsys.readouterr()
    assert "Hello" in captured.out
EOF

    cat > README.structure.md <<'EOF'
# Project Structure Overview

This layout was generated using the `create-repo.sh` scaffolding tool.

## 🐍 Python Project Structure

```text
.
├── .gitignore
├── README.md
├── README.structure.md
├── __init__.py
├── main.py
├── pyproject.toml
├── requirements.txt
├── docs/
│   ├── index.md
│   └── usage.md
├── logs/
│   └── .gitkeep
├── private/
│   ├── dummy-creds.md
│   └── SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
├── scratch/
├── src/
├── tests/
│   └── test_main.py
├── tmp/
│   └── SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
```
EOF

    TRACK_FILES+=(__init__.py main.py requirements.txt pyproject.toml tests/test_main.py README.structure.md)
    ;;

  bash)
    cat > src/main.sh <<EOF
#!/bin/bash

# Author: $AUTHOR_NAME <$AUTHOR_EMAIL>
# Date: $TODAY

echo "Hello from $REPO_NAME"
EOF
    chmod +x src/main.sh
    TRACK_FILES+=(src/main.sh)

    cat > README.structure.md <<'EOF'
# Project Structure Overview

This layout was generated using the `create-repo.sh` scaffolding tool.

## 🐚 Bash Project Structure

```text
.
├── .gitignore
├── README.md
├── README.structure.md
├── docs/
│   ├── index.md
│   └── usage.md
├── logs/
│   └── .gitkeep
├── private/
│   ├── dummy-creds.md
│   └── SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
├── scratch/
├── src/
│   └── main.sh
├── tests/
├── tmp/
│   └── SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
```
EOF
    TRACK_FILES+=(README.structure.md)
    ;;

  ruby)
    cat > src/main.rb <<EOF
#!/usr/bin/env ruby

# Author: $AUTHOR_NAME <$AUTHOR_EMAIL>
# Date: $TODAY

puts "Hello from $REPO_NAME"
EOF
    chmod +x src/main.rb
    TRACK_FILES+=(src/main.rb)

    cat > README.structure.md <<'EOF'
# Project Structure Overview

This layout was generated using the `create-repo.sh` scaffolding tool.

## 💎 Ruby Project Structure

```text
.
├── .gitignore
├── README.md
├── README.structure.md
├── docs/
│   ├── index.md
│   └── usage.md
├── logs/
│   └── .gitkeep
├── private/
│   ├── dummy-creds.md
│   └── SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
├── scratch/
├── src/
│   └── main.rb
├── tests/
├── tmp/
│   └── SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
```
EOF
    TRACK_FILES+=(README.structure.md)
    ;;
esac

git init --initial-branch=main
git add "${TRACK_FILES[@]}"
git commit -m "Initial commit with stubbed repo structure and $LANG scaffold"

echo "✅ Repo '$REPO_NAME' initialized with $LANG scaffold."
