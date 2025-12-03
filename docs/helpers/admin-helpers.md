# Admin Helper Functions

Functions for system administration tasks including hostname management, IP address retrieval, and environment variable configuration.

## Functions

### `update-hostname`

Updates the system hostname and domain name.

**Syntax:**
```bash
update-hostname <hostname> <domain>
```

**Parameters:**
- `$1` - Hostname (without domain)
- `$2` - Domain name

**Example:**
```bash
update-hostname myserver example.com
# Sets hostname to: myserver.example.com
```

**Actions:**
- Sets FQDN using `hostnamectl`
- Updates `/etc/hostname`
- Displays system IP addresses

**Requires:** sudo privileges

---

### `get-system-ips`

Displays all IP addresses associated with the system.

**Syntax:**
```bash
get-system-ips
```

**Output:**
Tab-separated list showing:
- IP address
- FQDN (hostname.domain)
- Hostname

**Example Output:**
```
192.168.1.100    myserver.example.com    myserver
10.0.0.5         myserver.example.com    myserver
```

**Note:** Usually called automatically by `update-hostname`, but can be used standalone.

---

### `add-environment-tag`

Adds environment variables to `/etc/environment` for system-wide persistence.

**Syntax:**
```bash
add-environment-tag <label> <value>
```

**Parameters:**
- `$1` - Environment variable name (label)
- `$2` - Environment variable value

**Example:**
```bash
add-environment-tag MYAPP_HOME /opt/myapp
# Adds: export MYAPP_HOME=/opt/myapp to /etc/environment
```

**Requires:** sudo privileges

**Note:** Variables persist across reboots and are available to all users.

---

### `user-exists`

Checks if a user exists on the system.

**Syntax:**
```bash
user-exists <username>
```

**Parameters:**
- `$1` - Username to check

**Example:**
```bash
user-exists john
# Outputs: USER_NAME: john
```

**Note:** Currently displays the username. Full implementation may return boolean in future versions.

