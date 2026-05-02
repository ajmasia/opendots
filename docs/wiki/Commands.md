# Commands

## Global options

| Flag | Short | Description |
|------|-------|-------------|
| `--dir <path>` | `-d` | Dotfiles repository path |
| `--profile <name>` | `-p` | Active profile |
| `--lang <lang>` | `-l` | UI language (`en` or `es`) |
| `--yes` | `-y` | Skip confirmation prompts |
| `--dry-run` | | Preview changes, write nothing |
| `--no-color` | | Disable coloured output |
| `--version` | | Print version and exit |
| `--help` | | Show usage and exit |

Global flags are accepted before or after the subcommand.

---

## dfy init

```
dfy init [--dir <path>] [--bare]
```

Initialise a new dotfiles git repository. Creates the directory, scaffolds starter packages (`bash-aliases`, `zsh-aliases`, `vim`), and writes `dir=<path>` to the config file.

`--bare` skips the scaffold and creates only the git repository.

---

## dfy link

```
dfy link <pkg...> [--profile <name>]
```

Link one or more packages into `$HOME` using stow. With `--profile`, links every package listed in the profile file.

Exits with code 1 when the package has no linkable files (only stow-ignored metadata like `README.md`) — run `dfy adopt` first to import existing files. Exits with code 3 when a target already exists as a real file. On conflict, two remedies are printed:

- `rm <files> && dfy link <pkg>` — delete the conflicting files and re-link (package version wins).
- `dfy adopt <pkg>` — move the existing files into the package (local version wins).

---

## dfy unlink

```
dfy unlink <pkg...> [--profile <name>]
```

Remove the symlinks created by `dfy link` or `dfy adopt`. Handles both file-level symlinks and directory-level symlinks (created when adopt empties a `$HOME` directory and stow replaces it with a single symlink to the package directory). The files in the dotfiles repository are not affected.

---

## dfy adopt

```
dfy adopt <pkg> [--yes]
```

Move existing `$HOME` files into the `<pkg>` package directory and replace them with symlinks, absorbing them into the dotfiles repository. Prompts for confirmation unless `--yes` is given.

Two complementary scans build the adoption list:

- **Package files**: any file already in the package whose corresponding `$HOME` path is a real file.
- **Package directories**: all real files found recursively under any `$HOME` directory that mirrors a directory in the package. This handles the typical flow where a package is created with an empty directory scaffold (e.g. `dfy create hyprland -s .config/hypr`) before any files are placed in it.

Files already managed by `dfy link` are never proposed.

---

## dfy status

```
dfy status [--profile <name>]
```

Show the link status of all packages:

| Symbol | Meaning |
|--------|---------|
| `[+]` | Linked |
| `[-]` | Not linked |
| `[!]` | Conflict (real file in `$HOME`) |

---

## dfy list

```
dfy list
```

List all packages with their one-line description from the package `README.md`.

---

## dfy info

```
dfy info <pkg>
```

Display the `README.md` of a package. Opens in `$EDITOR` when set; falls back to `cat`.

---

## dfy create

```
dfy create <pkg> [-s <subdir>] [--yes]
```

Scaffold a new package directory with a README template. The `-s`/`--subdir` flag pre-creates a subdirectory inside the package (e.g. `-s .config/btop` creates `<pkg>/.config/btop/`).

---

## dfy doctor

```
dfy doctor
```

Check for broken symlinks pointing into the dotfiles repository and warn about stow versions that are too old.

---

## dfy update

```
dfy update
```

Pull the latest changes from the Dotlify clone and refresh shell completions and the man page.

---

## dfy config

```
dfy config get <key>           # print the current value (shows default if unset)
dfy config set <key> <value>   # write or update a key
dfy config list                # list all keys with current value and default
dfy config edit                # open the config file in $EDITOR
```

Supported keys: `dir`, `lang`, `notifications`, `check_interval`, `remind_interval`.
See [Configuration](Configuration) for descriptions and defaults.

---

## dfy uninstall

```
dfy uninstall [--yes]
```

Remove the `dfy` symlink, shell completions, and man page. Optionally removes the clone directory and configuration.

---

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Generic error |
| 2 | Usage error (bad arguments, unknown subcommand) |
| 3 | Conflict (target file exists) |
| 4 | Missing runtime dependency |
