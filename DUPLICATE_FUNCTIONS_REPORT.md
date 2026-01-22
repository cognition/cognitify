# Duplicate Functions Report

This report identifies duplicate function names across the codebase. Functions with the same name may have different implementations or may be candidates for consolidation.

## Summary

The following functions appear in multiple files:

1. **log()** - 4 occurrences
2. **error()** - 4 occurrences  
3. **warn()** - 3 occurrences
4. **read_packages()** - 2 occurrences
5. **collect_packages()** - 2 occurrences
6. **install_packages()** - 2 occurrences
7. **parse_args()** - 2 occurrences
8. **usage()** - 2 occurrences
9. **main()** - 3 occurrences

## Detailed Analysis

### 1. log() function

**Locations:**
- `bin/install.sh:33` - Simple version: `printf "[cognitify] %s\n" "$*"`
- `post-install.sh:22` - Coloured version: `printf "${GREEN}[cognitify]${NC} %s\n" "$*" >&2`
- `package-distro.sh:31` - Coloured version: `printf "${GREEN}[package]${NC} %s\n" "$*"`
- `docker-test.sh:42` - Coloured version: `printf "${GREEN}[docker-test]${NC} %s\n" "$*"`
- `src/usr/local/bin/dirsync:64` - Different implementation: `echo "$(timestamp) $*"`

**Analysis:** These are utility logging functions with similar purposes but different implementations. The `dirsync` version is significantly different (uses timestamp). The others differ mainly in prefix and colour support.

**Recommendation:** Consider creating a shared logging library or standardizing the format.

---

### 2. error() function

**Locations:**
- `bin/install.sh:34` - Simple version: `printf "[cognitify] ERROR: %s\n" "$*" >&2`
- `post-install.sh:26` - Coloured version: `printf "${RED}[cognitify] ERROR:${NC} %s\n" "$*" >&2`
- `package-distro.sh:35` - Coloured version: `printf "${RED}[package] ERROR:${NC} %s\n" "$*" >&2`
- `docker-test.sh:46` - Coloured version: `printf "${RED}[docker-test] ERROR:${NC} %s\n" "$*" >&2`

**Analysis:** Similar to `log()`, these are utility error logging functions with consistent patterns but different prefixes.

**Recommendation:** Same as `log()` - consider shared library.

---

### 3. warn() function

**Locations:**
- `post-install.sh:30` - `printf "${YELLOW}[cognitify] WARNING:${NC} %s\n" "$*" >&2`
- `package-distro.sh:39` - `printf "${YELLOW}[package] WARNING:${NC} %s\n" "$*" >&2`
- `docker-test.sh:50` - `printf "${YELLOW}[docker-test] WARNING:${NC} %s\n" "$*" >&2`

**Analysis:** Consistent warning logging functions with different prefixes.

**Recommendation:** Same as `log()` and `error()`.

---

### 4. read_packages() function

**Locations:**
- `bin/install.sh:89` - Reads packages from file, skips comments
- `post-install.sh:52` - Similar implementation, reads packages from file

**Analysis:** These functions have nearly identical implementations. Both read package files and filter out comments/empty lines using awk.

**Recommendation:** **HIGH PRIORITY** - These are true duplicates and should be consolidated into a shared library or one should source the other.

---

### 5. collect_packages() function

**Locations:**
- `bin/install.sh:95` - Collects packages based on package manager
- `post-install.sh:65` - Similar implementation with Docker mode support

**Analysis:** These functions have similar logic but `post-install.sh` version includes Docker mode handling. They both read GENERAL and manager-specific package files.

**Recommendation:** **MEDIUM PRIORITY** - Consider consolidating with a parameter for Docker mode support.

---

### 6. install_packages() function

**Locations:**
- `bin/install.sh:117` - Installs packages using detected package manager
- `post-install.sh:103` - Similar implementation with update support

**Analysis:** Both functions install packages, but `post-install.sh` version includes package list updates and better error handling.

**Recommendation:** **MEDIUM PRIORITY** - Consider consolidating or ensuring both use the same logic.

---

### 7. parse_args() function

**Locations:**
- `configure:90` - Parses configure script arguments (extensive)
- `bin/install.sh:43` - Parses installer script arguments (simpler)

**Analysis:** These have different purposes and argument sets, so they're not true duplicates. However, they could potentially share common parsing logic.

**Recommendation:** **LOW PRIORITY** - Different purposes, but could share helper functions.

---

### 8. usage() function

**Locations:**
- `bin/install.sh:22` - Shows installer usage
- `docker-test.sh:17` - Shows docker-test script usage

**Analysis:** Different purposes, showing help for different scripts.

**Recommendation:** **LOW PRIORITY** - Acceptable as-is since they're script-specific.

---

### 9. main() function

**Locations:**
- `bin/install.sh:230` - Main installer entry point
- `package-distro.sh:246` - Main packaging entry point
- `post-install.sh:145` - Main post-install entry point

**Analysis:** Standard main entry points for different scripts.

**Recommendation:** **LOW PRIORITY** - Acceptable as-is, standard pattern.

---

## Related Functions (Similar Purpose, Different Names)

### detect_distro() vs ddistro()

**Locations:**
- `configure:35` - `detect_distro()` - Detects distribution and sets variables
- `src/bash.bashrc.d/lib/libCognitifyHelpers:59` - `ddistro()` - Detects distribution and returns specific values

**Analysis:** These functions have similar purposes (detecting Linux distribution) but different interfaces:
- `detect_distro()` sets global variables
- `ddistro()` returns specific values via echo

**Recommendation:** **MEDIUM PRIORITY** - Consider if these can be unified or if one should use the other.

---

## Recommendations Summary

### High Priority
1. **Consolidate `read_packages()`** - True duplicate with identical implementations
2. **Consolidate `collect_packages()`** - Very similar implementations

### Medium Priority
3. **Consolidate `install_packages()`** - Similar logic, different features
4. **Review `detect_distro()` vs `ddistro()`** - Similar purpose, different interfaces
5. **Create shared logging library** - For `log()`, `error()`, `warn()`

### Low Priority
6. **Standardize `parse_args()` helpers** - Different purposes but could share utilities
7. **Keep `usage()` and `main()`** - Script-specific, acceptable duplicates

---

---

## Duplicate Aliases

### In `src/bash.bashrc.d/aliasrc`

**True Duplicate:**
- **`v`** - Defined twice:
  - Line 73: `alias v='nvim'` (inside nvim check block)
  - Line 93: `alias v='nvim '` (standalone, has trailing space)
  
  **Issue:** The second definition will override the first. The trailing space difference is inconsistent.
  
  **Recommendation:** Remove the duplicate at line 93.

**Conditional Duplicates (Potential Conflicts):**
These aliases are defined conditionally based on tool availability, but if both tools are installed, the second definition will override the first:

- **`established`** - Line 137 (netstat) vs Line 155 (ss)
- **`established-l`** - Line 139 (netstat) vs Line 157 (ss)
- **`listening`** - Line 142 (netstat) vs Line 160 (ss)
- **`listening-l`** - Line 144 (netstat) vs Line 162 (ss)
- **`listening-u`** - Line 147 (netstat) vs Line 164 (ss)
- **`listening-lu`** - Line 149 (netstat) vs Line 165 (ss)

**Analysis:** The code checks for `netstat` first, then `ss`. If both are available, the `ss` versions will override the `netstat` versions. This may be intentional (preferring `ss`), but it's worth documenting or making explicit.

**Recommendation:** Consider adding a comment explaining the preference, or restructuring to use `elif` to ensure only one set is defined.

---

## Next Steps

1. **Fix duplicate alias `v`** - Remove the duplicate definition at line 93
2. Create a shared library file (e.g., `bin/lib/common-functions.sh`) for:
   - `log()`, `error()`, `warn()` functions
   - `read_packages()` function
   - Potentially `collect_packages()` and `install_packages()`
3. Refactor scripts to source the shared library
4. Review `detect_distro()` and `ddistro()` to determine if unification is possible
5. Review netstat/ss alias conflicts and add clarifying comments
6. Update version number after consolidation (per user rules)
