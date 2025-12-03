# Directory Helper Functions

Functions for managing empty directories.

## Functions

### `list-empty-dirs`

Lists all empty directories in the current directory tree.

**Syntax:**
```bash
list-empty-dirs
```

**Example:**
```bash
list-empty-dirs
# Outputs paths of all empty directories
```

**Search Scope:** Current directory and all subdirectories

**Use Case:** Find empty directories before cleanup

---

### `del-empty-dirs`

Deletes all empty directories in the current directory tree.

**Syntax:**
```bash
del-empty-dirs
```

**Example:**
```bash
del-empty-dirs
# Removes all empty directories recursively
```

**Warning:** This operation is irreversible. Use `list-empty-dirs` first to preview what will be deleted.

**Use Case:** Clean up empty directories after removing files

