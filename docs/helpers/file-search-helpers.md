# File Search Helper Functions

Functions for searching files with advanced filtering and execution capabilities.

## Functions

### `search-files`

Searches for files within a directory based on various criteria and optionally executes commands on results.

**Syntax:**
```bash
search-files [OPTIONS]
```

**Options:**
- `-d <directory>` - Directory to search in (default: current directory)
- `-t <type>` - File type/extension filter (e.g., txt, jpg)
- `-p <prefix>` - Regex pattern for file name prefix
- `-s <suffix>` - Regex pattern for file name suffix
- `-e <command>` - Command to execute on each file (use `{}` as placeholder)
- `-r` - Enable recursive search (include subdirectories)
- `-h` - Display help information

**Examples:**

```bash
# Find all .conf files
search-files -t conf

# Find files starting with "test" recursively
search-files -p "^test" -r

# Find .sh files and execute a command on each
search-files -t sh -e "chmod +x {}"

# Search in specific directory
search-files -d /etc -t conf -r
```

**Security Note:** File names are safely quoted before command execution to prevent injection attacks.

**Use Cases:**
- Batch file operations
- Finding files by pattern
- Recursive file processing
- File type filtering

