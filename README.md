# OpenDots

A Bash framework on top of [GNU Stow](https://www.gnu.org/software/stow/) for managing dotfiles on Linux and macOS.

## Requirements

- Bash ≥ 4.0
- GNU Stow ≥ 2.3.1
- figlet

> macOS ships Bash 3.2 by default — run `brew install bash` first.

## Usage

```
opendots install <pkg...>         Link packages from your dotfiles repo
opendots remove <pkg...>          Remove linked packages
opendots adopt <pkg>              Absorb existing files into a package
opendots list                     List available packages and link state
opendots status                   Show current state and active profile
opendots doctor                   Check for broken links and conflicts
opendots update                   Pull latest changes and refresh completions
opendots uninstall                Remove OpenDots from this system
```

Global flags: `--profile <name>`, `--dir <path>`, `--dry-run`, `--no-color`, `--yes`, `--version`, `--help`.

## Installation

### Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/opendots/main/install.sh | bash
```

The script clones OpenDots to `~/.local/share/opendots`, symlinks `opendots` into `~/.local/bin`, and installs shell completions.

### Manual install

```bash
git clone https://github.com/ajmasia/opendots ~/.local/share/opendots
bash ~/.local/share/opendots/install.sh
```

> The clone path must remain stable — `~/.local/bin/opendots` is a symlink into it.

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
opendots --dir examples/dotfiles list
opendots --dir examples/dotfiles --profile home install
```

## License

GPL-3.0-or-later — see [LICENSE](LICENSE).
