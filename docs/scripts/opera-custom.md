# opera-custom

Creates Opera browser shortcuts with separate user profiles.

## Synopsis

```bash
opera-custom <profile-name>
```

## Description

Creates a shortcut script in `~/bin/` to launch Opera with a separate user profile directory. Useful for running multiple Opera instances with different configurations.

## Parameters

- `<profile-name>` - Name for the profile (used in script and profile directory)

## Example

```bash
opera-custom work
# Creates: ~/bin/opera-work
# Profile directory: ~/.config/opera-work
```

## Usage

After creation, run:
```bash
~/bin/opera-work
```

## Features

- Checks for Opera installation
- Creates `~/bin/` if it doesn't exist
- Separate profile directory per shortcut
- Background execution (non-blocking)

## Profile Location

Profiles are stored in: `~/.config/opera-<profile-name>`

