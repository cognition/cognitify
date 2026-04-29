# Cognitify

Cognitify is a small set of **Bash** customisations you can drop onto a Linux host: a shared **environment** script (history, `PATH`, coloured prompt) and **home-directory** templates (`.bashrc`, overrides, Git, Vim, logout).

## Layout

| Path | Role |
|------|------|
| `src/etc/environment` | Interactive-shell entrypoint: history, `PATH`, restricted colour palette, prompt. Intended for **`/etc/environment`** (see below). |
| `src/home-files/bashrc` | Sources `/etc/environment`, then `~/.over-ride`, then applies the prompt; adds a minimal alias set. |
| `src/home-files/over-ride` | Per-user colour overrides (quote `export` values, e.g. `export OVERRIDE_HOSTNAME_COLOUR="${OLIVE}"`). |
| `src/home-files/gitconfig` | Template Git user config (edit placeholders before use). |
| `src/home-files/bash_logout` | Logout hook. |
| `src/home-files/vimrc` | Minimal Vim defaults. |

The prompt colours are driven by named variables defined in `src/etc/environment` (for example `OLIVE`, `AZURE`, `LT_BLUE`, `ROOT_RED`). Override them from `~/.over-ride` after the environment file has been sourced.

**Path note:** `~/.bashrc` sources **`/etc/environment`** (lowercase). Install `src/etc/environment` to that path, or adjust `ENVIRONMENT_FILE` in `.bashrc` if your site uses a different file (for example `/etc/Environment`).

## Quick install (manual)

As root (or with `sudo`), install the system file:

```bash
sudo install -m 0644 src/etc/environment /etc/environment
```

Then copy home templates into your account (back up any existing files first):

```bash
cp src/home-files/bashrc ~/.bashrc
cp src/home-files/over-ride ~/.over-ride
cp src/home-files/gitconfig ~/.gitconfig
cp src/home-files/bash_logout ~/.bash_logout
cp src/home-files/vimrc ~/.vimrc
```

Edit `~/.gitconfig` and `~/.over-ride` for your name, email, and colours. Open a new interactive shell to pick up changes.

## Tarball

A ready-made archive with `home/` and `etc/` at the top level is built as:

**`dist/cognitify-home-etc.tar.gz`**

Contents:

- `home/.bashrc`, `home/.over-ride`, `home/.gitconfig`, `home/.bash_logout`, `home/.vimrc`
- `etc/environment`

Extract and merge into your system, for example:

```bash
tar -xzf dist/cognitify-home-etc.tar.gz -C /tmp/cognitify-stage
sudo install -m 0644 /tmp/cognitify-stage/etc/environment /etc/environment
cp /tmp/cognitify-stage/home/.bashrc ~/
# … copy the rest of home/ as needed
```

Tarballs match `*.tar.gz` in `.gitignore`; regenerate locally if the file is missing.

## Full installer (optional)

For a complete Cognitify deployment (packages, completions, `/etc/bash.bashrc.d`, and so on), use **`sudo bin/install.sh`** or **`./configure` then `sudo make install`** as described in `BUILD.md`. That path expects the full `src/` tree (including `bash.bashrc.d`, `completions`, `packages`, etc.). If you only maintain the minimal tree above, prefer the manual or tarball flow.

## Maintenance

- Version: `version`; notes: `changelog`.
- Machine-specific or private material: `private/` (not tracked the same way as the rest of the tree—see `private/README.md` if present).

(c) 2026 Ramon Brooker <rbrooker@aeo3.io>
