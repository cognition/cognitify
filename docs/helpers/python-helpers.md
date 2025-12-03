# Python Helper Functions

Functions for Python development environment setup.

## Functions

### `setpyenv`

Creates a Python virtual environment using Python 3.12.

**Syntax:**
```bash
setpyenv <prompt-name> [env-dir]
```

**Parameters:**
- `$1` - Prompt name for the virtual environment (required)
- `$2` - Directory name for the virtual environment (default: `venv`)

**Example:**
```bash
setpyenv myproject
# Creates venv/ with prompt "myproject"

setpyenv myproject .venv
# Creates .venv/ with prompt "myproject"
```

**Actions:**
- Creates virtual environment using Python 3.12
- Activates the environment
- Upgrades pip to latest version

**Requirements:**
- Python 3.12 must be installed and available in PATH

**Error Handling:**
- Returns error if Python 3.12 is not found
- Returns error if prompt name is not provided

**Note:** The virtual environment is automatically activated in the current shell session.

