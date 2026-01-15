# Cognitify Helper Functions

Functions for general system operations, script generation, and utility tasks.

## Functions

### `note-addition`

Appends a timestamped note to a file.

**Syntax:**
```bash
note-addition "note text"
```

**Parameters:**
- `$1` - The note text to add

**Example:**
```bash
note-addition "Installed new package"
# Appends: "Installed new package -- Wed Dec 03 2026 - 14:30:45"
```

---

### `stub-script`

Creates a shell script template with executable permissions.

**Syntax:**
```bash
stub-script <script-name>
```

**Parameters:**
- `$1` - Name of the script (without .sh extension)

**Example:**
```bash
stub-script myscript
# Creates myscript.sh with template content
```

**Features:**
- Includes copyright header from `SCRIPT_SIGNATURE_BLOCK`
- Sets executable permissions
- Checks for existing files

---

### `ddistro`

Detects and returns Linux distribution information.

**Syntax:**
```bash
ddistro [index]
```

**Parameters:**
- `index` (optional) - Which detail to return:
  - `0` - Distribution ID (e.g., "ubuntu", "fedora")
  - `1` - Version ID (e.g., "22.04", "38")
  - `2` - Distribution family (e.g., "debian", "fedora", "suse")
  - `3` - Package manager (default, e.g., "apt-get", "yum", "zypper")

**Examples:**
```bash
ddistro        # Returns: apt-get
ddistro 0     # Returns: ubuntu
ddistro 1     # Returns: 22.04
ddistro 2     # Returns: debian
ddistro 3     # Returns: apt-get
```

**Supported Distributions:**
- Debian/Ubuntu/Mint → apt-get
- RHEL/CentOS/Oracle/Fedora/Rocky/AlmaLinux/Azure Linux/Amazon → yum/dnf
- openSUSE/SLES → zypper

---

### `group-check`

Checks if the current user is part of a specified group.

**Syntax:**
```bash
group-check <group-name>
```

**Parameters:**
- `$1` - Name of the group to check

**Returns:**
- `true` - User is in the group
- `false` - User is not in the group

**Example:**
```bash
group-check sudo
# Returns: true or false
```

---

### `app-is-there`

Determines if an application is accessible in common search paths.

**Syntax:**
```bash
app-is-there <app-name>
```

**Parameters:**
- `$1` - Application name to check

**Returns:**
- Exit code `0` - Application found
- Exit code `1` - Application not found

**Searches in:**
- `/usr/local/bin`
- `/usr/bin`
- `/usr/local/sbin`
- `/usr/sbin`
- `~/.local/bin`
- `~/.bin`

**Example:**
```bash
if app-is-there vim; then
    echo "vim is installed"
fi
```

---

### `app-values`

Returns a numeric value indicating if an application is present.

**Syntax:**
```bash
app-values <app-name>
```

**Parameters:**
- `$1` - Application name to check

**Returns:**
- `0` - Application is present
- `1` - Application is not present

**Example:**
```bash
status=$(app-values git)
echo "Git status: $status"
```

---

### `find-latency`

Measures and lists network latency to specified addresses.

**Syntax:**
```bash
find-latency <address1> [address2] ...
```

**Parameters:**
- `$@` - List of IP addresses or hostnames to ping

**Example:**
```bash
find-latency 8.8.8.8 1.1.1.1
# Pings each address 5 times and shows sorted latency results
```

**Output:**
Shows sorted latency times for each address, sorted numerically.

