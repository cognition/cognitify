# Cognitify Enterprisy Version

Minimal **Bash** and **Vim** dotfiles plus a single system-wide **environment** script: history, `PATH`, a coloured prompt, and a small set of named colours you can override per user.

Version is recorded in `version`.

## Repository layout

```
cognitify/
├── .gitignore
├── README.md
├── version
├── dist/
│   └── cognitify-home-etc.tar.gz   # optional bundle (see below)
└── src/
    ├── etc/
    │   └── environment             # install as /etc/environment (see note)
    └── home-files/
        ├── bash_logout
        ├── bashrc
        ├── gitconfig
        ├── over-ride
        └── vimrc
```


| File                         | Purpose                                                                                                                |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `src/etc/environment`        | Sourced for interactive shells: `shopt`/history, `PATH`, colour names, `_cognitify_apply_prompt`, `PS1`.               |
| `src/home-files/bashrc`      | Sources `/etc/environment`, then `~/.over-ride`, reapplies the prompt, defines a few aliases.                          |
| `src/home-files/over-ride`   | Per-user exports (e.g. `export OVERRIDE_HOSTNAME_COLOUR="${OLIVE}"` — **quote** values that contain escape sequences). |
| `src/home-files/gitconfig`   | Git template; replace placeholders before use.                                                                         |
| `src/home-files/bash_logout` | Logout script.                                                                                                         |
| `src/home-files/vimrc`       | Vim configuration.                                                                                                     |


**System path:** `bashrc` uses `ENVIRONMENT_FILE="/etc/environment"`. Install the repo file as that path (lowercase), or change `ENVIRONMENT_FILE` in your `~/.bashrc` if your distribution uses another file.

## Install

### 1. System environment (root)

```bash
sudo install -m 0644 src/etc/environment /etc/environment
```

### 2. Home directory (your user)

Copy each template to `$HOME` with a leading dot:

```bash
for f in src/home-files/*; do
  cp "$f" "$HOME/.$(basename "$f")"
done
```

Or unpack `**dist/cognitify-home-etc.tar.gz**`, which contains `home/.bashrc`, `home/.over-ride`, and the rest under `home/`, plus `etc/environment`:

```bash
tar -xzf dist/cognitify-home-etc.tar.gz -C /tmp/cognitify-stage
sudo install -m 0644 /tmp/cognitify-stage/etc/environment /etc/environment
cp /tmp/cognitify-stage/home/.??* "$HOME/"
```

Edit `~/.gitconfig` and `~/.over-ride` as needed, then open a **new interactive** Bash session.

### Tarball and git

`*.tar.gz` is listed in `.gitignore`; the archive under `dist/` may be present locally but not committed. Regenerate it from the current `src/` tree when you need a fresh bundle:

```bash
mkdir -p dist stage/home stage/etc
cp src/home-files/bashrc stage/home/.bashrc
cp src/home-files/over-ride stage/home/.over-ride
cp src/home-files/gitconfig stage/home/.gitconfig
cp src/home-files/bash_logout stage/home/.bash_logout
cp src/home-files/vimrc stage/home/.vimrc
cp src/etc/environment stage/etc/environment
tar -czf dist/cognitify-home-etc.tar.gz -C stage home etc
rm -rf stage
```

## Maintenance

- Bump `version` when you cut a release or meaningful change.
- `private/` and similar paths are ignored by `.gitignore` for local-only material.

(c) 2026 Ramon Brooker [rbrooker@aeo3.io](mailto:rbrooker@aeo3.io)