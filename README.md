# Dotlify

[![CI](https://github.com/ajmasia/dotlify/actions/workflows/ci.yml/badge.svg)](https://github.com/ajmasia/dotlify/actions/workflows/ci.yml)
[![License: GPL-3.0-or-later](https://img.shields.io/badge/license-GPL--3.0--or--later-blue)](LICENSE)
[![Shell: bash ≥ 4](https://img.shields.io/badge/shell-bash%20%E2%89%A54-green)](https://www.gnu.org/software/bash/)
[![Platform: Linux/macOS](https://img.shields.io/badge/platform-linux%20%7C%20macos-orange)](https://github.com/ajmasia/dotlify)
[![Version](https://img.shields.io/github/v/tag/ajmasia/dotlify?label=version)](https://github.com/ajmasia/dotlify/tags)
[![Tests](https://img.shields.io/badge/tests-bats-purple)](https://bats-core.readthedocs.io/)
[![Nix flake](https://img.shields.io/badge/nix-flake-5277C3?logo=nixos)](https://github.com/ajmasia/dotlify/blob/main/flake.nix)

A Bash framework on top of [GNU Stow](https://www.gnu.org/software/stow/) for managing dotfiles on Linux and macOS.

## Getting started

After installing Dotlify, create your dotfiles repository:

```bash
dfy init
```

This creates `~/.dotfiles`, initialises a git repo, and scaffolds a few commented starter files (`bash-aliases`, `zsh-aliases`, `vim`). Link it to a remote when ready:

```bash
cd ~/.dotfiles
git remote add origin <your-remote-url>
git push -u origin main
```

Then adopt your existing dotfiles or apply packages:

```bash
dfy adopt vim       # absorb existing ~/.vimrc into the vim package
dfy apply vim       # link the vim package back into $HOME
```

Use `--bare` to skip the scaffold and create only the git repo:

```bash
dfy init --bare --dir ~/my-dots
```

## Requirements

- Linux (kernel ≥ 4.x) or macOS (10.15+)
- Bash ≥ 4.0 — macOS ships with bash 3.2; install with `brew install bash`
- GNU Stow ≥ 2.3.1 — `brew install stow` on macOS
- figlet — `brew install figlet` on macOS

## Usage

```
dfy apply <pkg...>                Apply packages from your dotfiles repo
dfy unlink <pkg...>               Remove symlinks for packages
dfy adopt <pkg>                   Absorb existing files into a package
dfy list                          List available packages
dfy info <pkg>                    Show a package's README
dfy create <pkg>                  Scaffold a new package
dfy init [--dir <path>] [--bare]  Bootstrap a new dotfiles repo
dfy config get <key>              Print a config value
dfy config set <key> <value>      Write a config value
dfy config list                   List all config keys and current values
dfy config edit                   Open the config file in $EDITOR
dfy status                        Show current state and active profile
dfy doctor                        Check for broken links and conflicts
dfy update                        Pull latest changes and refresh completions
dfy uninstall                     Remove Dotlify from this system
```

Global flags: `--profile <name>`, `--dir <path>`, `--dry-run`, `--no-color`, `--yes`, `--version`, `--help`.

Full reference: `man dfy`.

## Installation

### Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash
```

The script clones Dotlify to `~/.local/share/dotlify`, symlinks `dfy` into `~/.local/bin`, and installs shell completions.

### Nix

```bash
nix profile install github:ajmasia/dotlify
```

Or add it to your `flake.nix`:

```nix
inputs.dotlify.url = "github:ajmasia/dotlify";
```

`bash`, `stow`, and `figlet` are provided automatically by the derivation.
To upgrade: `nix profile upgrade dotlify`. To remove: `nix profile remove dotlify`.

> **Man page on macOS / non-NixOS**: add `~/.nix-profile/share/man` to `MANPATH`.

### Manual install

```bash
git clone https://github.com/ajmasia/dotlify ~/.local/share/dotlify
bash ~/.local/share/dotlify/install.sh
```

> The clone path must remain stable — `~/.local/bin/dfy` is a symlink into it.

## Configuration

Dotlify reads `~/.config/dotlify/config` (INI-style). Supported keys:

| Key | Description | Default |
|-----|-------------|---------|
| `dir` | Path to your dotfiles repo | `~/.dotfiles` |
| `lang` | UI language (`en` or `es`) | `en` |
| `notifications` | Enable passive git-status checks | `true` |
| `check_interval` | Seconds between git-status checks | `86400` (24 h) |
| `remind_interval` | Seconds before showing an idle reminder | `604800` (7 days) |

Environment variables override the config file and take precedence:

| Variable | Description |
|----------|-------------|
| `DFY_DIR` | Path to your dotfiles repo |
| `DFY_PROFILE` | Active profile name |
| `DFY_LANG` | UI language (`en` or `es`) |
| `DFY_DRY_RUN` | Set to `1` to preview changes |
| `DFY_YES` | Set to `1` to skip confirmation prompts |
| `DFY_NO_COLOR` | Set to `1` to disable colored output |

## Development

Activate the pre-commit hook once per clone:

```bash
git config core.hooksPath .githooks
```

Then use the Makefile:

```bash
make lint       # shellcheck
make fmt        # shfmt -w
make fmt-check  # shfmt -d (CI)
make test       # bats tests/
make check      # lint + fmt-check + test
```

## Documentation

- `man dfy` — full man page (installed with `install.sh`)
- [Wiki](https://github.com/ajmasia/dotlify/wiki) — installation, commands, configuration, profiles, examples
- `dfy --help` / `dfy <subcommand> --help` — inline help

## License

GPL-3.0-or-later — see [LICENSE](LICENSE).
