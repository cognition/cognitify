# README Update Instructions

Add the following section to README.md after the "What's in the box" section:

```markdown
## Documentation

Comprehensive documentation is available for all helper functions and utility scripts:

- **[Documentation Catalog](docs/index.md)** - Complete catalog of all helpers and scripts
- **[Helper Functions](docs/helpers/)** - Detailed documentation for helper function libraries
- **[Utility Scripts](docs/scripts/)** - Documentation for command-line utilities

### Quick Reference

View the man page after installation:
```bash
man cognitify
```

Or browse the documentation online in the `docs/` directory.
```

Add this to the "Installation" section:

```markdown
## Installation

### Using the Build System (Recommended)

```bash
./configure
make
sudo make install
```

See [BUILD.md](BUILD.md) for detailed build instructions.

### Using the Installer Script

Run the installer as root (or via `sudo`) from the repository root:
```

