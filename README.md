# Dotlify

A Bash framework on top of [GNU Stow](https://www.gnu.org/software/stow/) for managing dotfiles on Linux and macOS.

## Requirements

- Bash ≥ 4.0
- GNU Stow ≥ 2.3.1
- figlet

> macOS ships Bash 3.2 by default — run `brew install bash` first.

## Usage

```
dfy install <pkg...>         Link packages from your dotfiles repo
dfy remove <pkg...>          Remove linked packages
dfy adopt <pkg>              Absorb existing files into a package
dfy list                     List available packages
dfy status                   Show current state and active profile
dfy doctor                   Check for broken links and conflicts
dfy update                   Pull latest changes and refresh completions
dfy uninstall                Remove Dotlify from this system
```

Global flags: `--profile <name>`, `--dir <path>`, `--dry-run`, `--no-color`, `--yes`, `--version`, `--help`.

## Installation

### Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash
```

The script clones Dotlify to `~/.local/share/dotlify`, symlinks `dfy` into `~/.local/bin`, and installs shell completions.

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
| `lang` | UI language (`en` or `es`) | system locale |

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

## Example dotfiles repo

The [`examples/dotfiles/`](examples/dotfiles/) directory shows a minimal dotfiles repo layout with two packages (`git`, `tmux`) and a `home` profile. Use it as a reference or copy it as a starting point:

```
examples/dotfiles/
├── git/
│   └── .gitconfig
├── tmux/
│   └── .tmux.conf
└── profiles/
    └── home.txt      # lists: git, tmux
```

```bash
dfy --dir examples/dotfiles list
dfy --dir examples/dotfiles --profile home install
```

## License

GPL-3.0-or-later — see [LICENSE](LICENSE).
