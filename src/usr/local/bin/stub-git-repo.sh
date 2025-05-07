#!/bin/bash

# Usage: ./create-repo.sh <repo-name> --name "Your Name" --email "you@example.com" [--lang python|bash|ruby]

set -e

REPO_NAME=""
CLI_NAME=""
CLI_EMAIL=""
LANG=""
TODAY=$(date +"%Y-%m-%d")

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --lang)
      LANG="$2"
      shift; shift
      ;;
    --name)
      CLI_NAME="$2"
      shift; shift
      ;;
    --email)
      CLI_EMAIL="$2"
      shift; shift
      ;;
    *)
      if [ -z "$REPO_NAME" ]; then
        REPO_NAME="$1"
        shift
      else
        shift
      fi
      ;;
  esac
done

# Determine author info
AUTHOR_NAME="${CLI_NAME:-$AUTHOR_NAME}"
AUTHOR_EMAIL="${CLI_EMAIL:-$AUTHOR_EMAIL}"

if [ -z "$REPO_NAME" ] || [ -z "$AUTHOR_NAME" ] || [ -z "$AUTHOR_EMAIL" ]; then
  echo "Usage: $0 <repo-name> --name \"Your Name\" --email \"you@example.com\" [--lang python|bash|ruby]"
  echo "Alternatively, set AUTHOR_NAME and AUTHOR_EMAIL as environment variables."
  exit 1
fi

mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# Create directories
mkdir -p src docs test logs private tmp scratch

# Placeholder files
echo "SHOULD_BE_EMPTY_IN_SOURCE_CONTROL" > private/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
echo "SHOULD_BE_EMPTY_IN_SOURCE_CONTROL" > tmp/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
touch logs/.gitkeep

# Credential guidance
cat > private/dummy-creds.md <<EOF
# Credential Format Documentation

Author: $AUTHOR_NAME <$AUTHOR_EMAIL>  
Date: $TODAY

Use this file to document the format the credentials should take, but **do not include** the actual credentials here.
EOF

# Documentation
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

# README with author info and docs link
cat > README.md <<EOF
# $REPO_NAME

Author: $AUTHOR_NAME <$AUTHOR_EMAIL>  
Created: $TODAY

Project description goes here.

📚 [Documentation](docs/index.md)
EOF

# .gitignore with placeholders
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

# Track list
TRACK_FILES=(
  README.md .gitignore
  docs/index.md docs/usage.md
  logs/.gitkeep
  private/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
  private/dummy-creds.md
  tmp/SHOULD_BE_EMPTY_IN_SOURCE_CONTROL
)

# Language-specific scaffolding
case "$LANG" in
  python)
    mkdir -p src/$REPO_NAME
    cat > src/$REPO_NAME/__init__.py <<EOF
# Init for $REPO_NAME package
EOF

    cat > src/$REPO_NAME/__main__.py <<EOF
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

    TRACK_FILES+=(
      src/$REPO_NAME/__init__.py
      src/$REPO_NAME/__main__.py
      requirements.txt
      pyproject.toml
    )
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
    ;;
esac

# Initialize Git using 'main' as default branch
git init --initial-branch=main
git add "${TRACK_FILES[@]}"
git commit -m "Initial commit with stubbed repo structure and $LANG scaffold"
