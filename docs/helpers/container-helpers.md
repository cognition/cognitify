# Container Helper Functions

Functions for managing Docker and Podman containers and images.

## Docker Functions

### `docker-list-types`

Lists Docker images matching a specific reference pattern.

**Syntax:**
```bash
docker-list-types <pattern>
```

**Parameters:**
- `$1` - Reference pattern to filter images (e.g., 'a', '<none>', 'Exited')

**Example:**
```bash
docker-list-types '<none>'
# Lists all dangling images
```

**Returns:** Image IDs matching the pattern

---

### `docker-cleanup-old-builds`

Removes old Docker build images (dangling images).

**Syntax:**
```bash
docker-cleanup-old-builds
```

**Example:**
```bash
docker-cleanup-old-builds
# Removes all dangling Docker images
```

**Note:** Uses `docker-list-types '<none>'` to find images to remove.

---

### `docker-cleanup-containers`

Deletes all exited Docker containers.

**Syntax:**
```bash
docker-cleanup-containers
```

**Example:**
```bash
docker-cleanup-containers
# Removes all stopped containers
```

---

### `shell-into-docker`

Enters a Docker container with an interactive bash shell.

**Syntax:**
```bash
shell-into-docker <container-id-or-name>
```

**Parameters:**
- `$1` - Container ID or name

**Example:**
```bash
shell-into-docker mycontainer
# Opens interactive bash shell in the container
```

**Equivalent to:** `docker exec -it <container> /bin/bash`

---

## Podman Functions

### `podman-cleanup-old-builds`

Removes old Podman build images (dangling images).

**Syntax:**
```bash
podman-cleanup-old-builds
```

**Example:**
```bash
podman-cleanup-old-builds
# Removes all dangling Podman images
```

---

### `podman-cleanup-containers`

Deletes all exited Podman containers.

**Syntax:**
```bash
podman-cleanup-containers
```

**Example:**
```bash
podman-cleanup-containers
# Removes all stopped Podman containers
```

---

### `pod-shell-into`

Enters a Podman container with an interactive bash shell.

**Syntax:**
```bash
pod-shell-into <container-id-or-name>
```

**Parameters:**
- `$1` - Container ID or name

**Example:**
```bash
pod-shell-into mycontainer
# Opens interactive bash shell in the Podman container
```

**Equivalent to:** `podman exec -it <container> /bin/bash`

