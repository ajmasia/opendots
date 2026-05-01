# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.10.0] — 2026-05-01

### Added
- `dfy init [--dir <path>] [--bare]`: creates a dotfiles git repo, scaffolds starter packages (`bash-aliases`, `zsh-aliases`, `vim`) and a root `.gitignore`, writes `dir=<path>` to `~/.config/dotlify/config`, and prints a remote-linking reminder.
- `lib/config.sh`: `config::get` and `config::set` helpers for reading and writing the `~/.config/dotlify/config` key=value store.
- `install.sh`: post-install hint prompting the user to run `dfy init`.
- README: "Getting started" section with `dfy init` walkthrough.

## [0.9.0] — 2026-05-01

### Added
- `dfy info <pkg>`: prints the full README of a package; shows `[i] No README found` when absent.
- `dfy create <pkg>`: scaffolds a new package directory with a README template (Dependencies, Setup, Notes sections). If the package already exists but has no README, creates only the README. Prompts for a description; `--yes` skips the prompt.
- `repo::pkg_description`: extracts a one-line synopsis from `<pkg>/README.md` — first prose line after the heading, falling back to the heading text, or `(no description)` for an empty README.
- `MSG_STATUS_NOT_LINKED` locale key for the new status section.

### Changed
- `dfy install` renamed to `dfy apply` — clearer semantics (applies stow links, does not install software).
- `dfy remove` renamed to `dfy unlink` — pairs naturally with `apply`; output now includes a hint that package files remain in the repository.
- `dfy list`: redesigned output — `[i] <pkg> (<description>)` for packages with a README, `[!] <pkg> (no readme)` for those without.
- `dfy status`: packages grouped into sections (Linked / Conflicts / Not linked) each preceded by a `[>]` header.
- CI: workflow now triggers only on version tags (`v*.*.*`), not on every branch push.

## [0.8.4] — 2026-05-01

### Changed
- UX: blank line after `[>]` step message and after external command output (git clone/pull) to visually separate blocks.
- UX: blank line after each `[?]` prompt+answer before the result, applied consistently in `uninstall`, `adopt`, and `install.sh`.
- `install.sh`: `[+] Dotlify installed successfully!` no longer preceded by a blank line — keeps it in the same result block as the preceding `[+]` lines.

## [0.8.3] — 2026-05-01

### Fixed
- `install.sh`: fix escape sequences printed as literal text when piped from curl (use `$'\033[...]'` quoting).

### Changed
- `uninstall`: confirmation prompts now use `[?]` prefix via new `ui::ask` helper; blank line added before each prompt.
- `adopt`: confirmation prompt uses `ui::ask` for consistent `[?]` prefix.
- `install.sh`: dependency install prompt uses `_ui_ask` for consistent `[?]` prefix.

## [0.8.2] — 2026-05-01

### Changed
- README updated for Dotlify rename: binary name, install URL, clone path, and new configuration reference table.

## [0.8.1] — 2026-05-01

### Changed
- `install.sh`: colorized output with inline Catppuccin Mocha helpers (`_ui_step`, `_ui_ok`, `_ui_info`, `_ui_warn`, `_ui_error`, `_ui_section`, `_ui_value`, `_ui_muted`).
- `uninstall`: paths and prompts colorized via `ui::ok`, `ui::info`, and `theme::accent`/`theme::muted`.

## [0.8.0] — 2026-05-01

### Changed
- Project renamed from OpenDots to **Dotlify**; binary renamed from `opendots` to `dfy`.
- Environment variables renamed from `DOTS_*` to `DFY_*` (`DFY_DIR`, `DFY_PROFILE`, `DFY_LANG`, `DFY_DRY_RUN`, `DFY_YES`, `DFY_NO_COLOR`).
- Config directory moved from `~/.config/opendots/` to `~/.config/dotlify/`.
- Completion scripts renamed to `dfy.bash` and `_dfy`.
- Version constant renamed from `OPENDOTS_VERSION` to `DOTLIFY_VERSION`.

## [0.7.7] — 2026-04-30

### Changed
- `list`: now shows only package names with a `-` prefix — pure inventory of the dotfiles repo, no status indicators.
- `status`: shows all packages with `[ok]` / `[off]` / `[warn]` per package. Conflict entries include an adopt hint. Adds `ui::off` helper (muted color) for unlinked packages.

## [0.7.6] — 2026-04-30

### Changed
- `opendots list` now uses `ui::ok`, `ui::warn`, and `ui::info` instead of bare symbols (`✓`, `!`, `·`), consistent with the rest of the CLI output.

## [0.7.5] — 2026-04-30

### Fixed
- `repo::package_status` now correctly reports `✓` for packages where stow used tree folding (directory-level symlink instead of per-file symlinks). Uses `readlink -f` to check whether the resolved path falls inside the package directory, regardless of whether the symlink is on the file or on an ancestor directory.

## [0.7.4] — 2026-04-30

### Fixed
- `dir=` in `~/.config/opendots/config` now accepts both `~`-relative paths (`~/dotfiles`) and absolute paths (`/home/user/dotfiles`). Leading `~` is expanded to `$HOME` when reading the config value in `repo.sh` and both completion files.

## [0.7.3] — 2026-04-30

### Changed
- Binary renamed from `dots` to `opendots` — avoids collisions with `dot`, `dotty`, `dotlockfile`, etc. on Debian/Ubuntu systems.
- Config directory moved from `~/.config/dots/` to `~/.config/opendots/` to match the new binary name.
- Completion files renamed: `completions/dots.bash` → `completions/opendots.bash`, `completions/_dots` → `completions/_opendots`; all internal function names updated (`_dots_*` → `_opendots_*`).
- `install.sh`: binary link is now `~/.local/bin/opendots`; completion paths updated accordingly.

### Added
- `opendots update`: runs `git pull --ff-only` in the clone directory and reinstalls shell completions.
- `opendots uninstall`: removes binary symlink, shell completions, and (with confirmation) the config directory and the clone itself.

## [0.7.2] — 2026-04-30

### Fixed
- `install.sh`: guard entry condition now uses `${BASH_SOURCE[0]:-}` in the equality check to avoid unbound variable error under `set -u` when piped via `curl | bash`.

## [0.7.1] — 2026-04-30

### Added
- `install.sh`: curl-pipe support — when run via `curl -fsSL URL | bash`, the script detects it is not executing from a local file, checks for `git`, clones the repo to `~/.local/share/opendots` (or pulls if the clone already exists), and continues with the normal installation flow.
- `README.md`: Quick install section with `curl | bash` one-liner; manual install section with explicit clone URL.

## [0.7.0] — 2026-04-30

### Added
- `install.sh`: bootstrap installer — detects distro (`/etc/os-release`) and maps to `apt`/`pacman`/`dnf`; detects macOS via `uname` + `brew`; checks bash ≥ 4 (exit 4) and stow ≥ 2.3.1 (exit 4); installs missing `stow`/`figlet` with y/N confirmation (`--yes` to skip); symlinks `~/.local/bin/dots → <clone>/bin/dots`; installs bash and zsh completions to XDG-standard user paths; prints post-install PATH/fpath instructions.
- `examples/dotfiles/`: minimal reference layout with `git` and `tmux` packages and a `home` profile. Documented in `README.md`.
- `tests/install/detect.bats`: 7 distro-detection tests with os-release fixtures (ubuntu, debian, arch, manjaro, fedora, rocky, alpine).
- `tests/install/install.bats`: 10 tests covering compose_cmd per package manager, `--yes` flag, unrecognized-distro exit 1, bash < 4 exit 4, stow < 2.3.1 exit 4, symlink and completion installation.
- `tests/test_helper.bash`: `EXAMPLES_DIR` constant pointing to `examples/dotfiles/`.

### Fixed
- `tests/test_helper.bash`: `setup_dots_dir` and `setup_home` now resolve temp paths to canonical form via `pwd -P` so `assert_symlink` comparisons match on macOS (where `/var → /private/var`). `teardown_dirs` uses resolved `$TMPDIR` instead of the hard-coded `/tmp` prefix so cleanup works on both platforms.
- `completions/_dots`: `_dots "$@"` auto-call is now guarded by `(( ${+CURRENT} ))` so it only fires inside zsh's completion system, not when sourced in tests.
- `tests/lib/i18n.bats`: `unset XDG_CONFIG_HOME` added to setup, consistent with `repo.bats` and `profile.bats`, so the test is not affected by runner environment.

## [0.6.0] — 2026-04-30

### Added
- `completions/dots.bash`: bash tab completion — subcommands, packages, profile names, and global flags. Source in `~/.bashrc` or drop in `/etc/bash_completion.d/`.
- `completions/_dots`: zsh tab completion with `_arguments`/`_describe` patterns. Place in an `$fpath` directory.
- `tests/completions/bash.bats`: 12 bats tests simulating `COMP_WORDS`/`COMP_CWORD` for the bash completion function.
- `tests/completions/zsh.bats`: zsh helper-function tests via `zsh -c`; skip cleanly when zsh is absent.
- CI (Linux): `zsh` added to the apt install step so zsh completion tests run on Linux runners.

### Fixed
- `tests/cli/help.bats`: `--version` assertion updated to match current version.

## [0.5.0] — 2026-04-30

### Added
- `lib/repo.sh`: `repo::resolve_dir` now reads `dir=` from `~/.config/dots/config` as fallback before `~/.dotfiles`. Precedence: `--dir` > `$DOTS_DIR` > config file > `~/.dotfiles`.
- `lib/profile.sh`: `profile::dir`, `profile::load`, `profile::exists` — read `<DOTS_DIR>/profiles/<name>.txt`, strip comments and blank lines.
- `dots install --profile <name>`: expands to the listed packages and installs them.
- `dots remove --profile <name>`: expands to the listed packages and removes them.
- `dots --dry-run install --profile <name>`: resolves profile and simulates install without touching disk.
- `dots status`: reports active profile name or `(no active profile)` per-invocation.
- `locales/en.sh`, `locales/es.sh`: Phase 5 `MSG_PROFILE_*` and `MSG_STATUS_PROFILE` / `MSG_STATUS_NO_PROFILE` strings.
- `tests/lib/repo.bats`: tests for `dir=` config file support in `repo::resolve_dir`.
- `tests/lib/profile.bats`: unit tests for `profile::load` / `profile::exists`.
- `tests/cmd/profile.bats`: integration tests — install/remove/dry-run with profile, missing profile error, status with/without profile.

## [0.4.0] — 2026-04-30

### Added
- `lib/os.sh`: `os::is_macos`, `os::is_linux`, `os::distro_id` helpers.
- `lib/repo.sh`: `repo::resolve_dir` (precedence: `--dir` > `$DOTS_DIR` > `~/.dotfiles`), `repo::list_packages`, `repo::package_status` (✓ / · / ! markers).
- `lib/cmd_install.sh`: real stow-based install with pre-flight conflict detection (exit 3); `--dry-run` runs `stow -n` and shows planned operations via `[info]`.
- `lib/cmd_remove.sh`: idempotent `stow -D`; silent no-op when package is not linked.
- `lib/cmd_adopt.sh`: `stow --adopt` with file preview and interactive confirmation; `--yes` skips prompt.
- `lib/cmd_list.sh`: per-package status table with ✓ / · / ! markers.
- `lib/cmd_status.sh`: linked packages and conflicts summary.
- `lib/cmd_doctor.sh`: checks bash ≥ 4, stow ≥ 2.3.1, and broken symlinks under `$HOME` pointing into `$DOTS_DIR`.
- `locales/en.sh`, `locales/es.sh`: Phase 4 MSG_* strings for all new commands.
- `tests/cmd/`: bats integration tests for install, remove, adopt, list, status, and doctor.
- `tests/test_helper.bash`: `make_package` fixture helper.

### Fixed
- `lib/args.sh`: `DOTS_DIR`, `DOTS_LANG`, `DOTS_PROFILE` now preserve existing env var values instead of being clobbered on source.

## [0.3.0] — 2026-04-30

### Added
- `locales/en.sh` and `locales/es.sh`: all Phase 3 user-facing strings as `MSG_*` variables; both locales kept in sync.
- `lib/i18n.sh`: `i18n::load <lang>` (sources locale file, falls back to `en`); `i18n::configured_lang` (reads `lang=` from `~/.config/dots/config`).
- `lib/args.sh`: global flag parser (`--help`, `-h`, `--version`, `-V`, `--no-color`, `--dry-run`, `--profile`, `--dir`, `--yes`, `-y`, `--lang`); subcommand dispatcher with per-subcommand `--help` delegation and closest-match suggestion on unknown subcommand.
- `lib/cmd_help.sh`: `cmd_help::run` (banner + full usage table), `cmd_help::show_version` (banner + version line), `cmd_help::run_subcmd` (per-subcommand usage without banner).
- `lib/cmd_{install,remove,adopt,list,status,doctor}.sh`: not-implemented stubs for all Phase 4 subcommands.
- `bin/dots`: main entrypoint — resolves `DOTS_LIB` from real path, checks bash ≥ 4 (exit 4), sources libraries, parses global flags, loads i18n, and dispatches.
- `tests/lib/i18n.bats`: unit tests for `i18n::load` (en, es, unknown fallback) and `i18n::configured_lang`.
- `tests/cli/help.bats`, `tests/cli/dispatch.bats`, `tests/cli/i18n.bats`: integration tests covering `--help`, `--version`, bare invocation, unknown subcommand/flag, `--no-color`, and `--lang` flag with Spanish/fallback behavior.

## [0.2.0] — 2026-04-30

### Added
- `lib/theme.sh`: Catppuccin Mocha palette as 24-bit truecolor escapes; semantic role helpers (`theme::accent`, `theme::text`, `theme::subtext`, `theme::success`, `theme::warning`, `theme::error`, `theme::info`, `theme::reset`); `theme::supports_color` with `THEME_COLORS_ENABLED` flag; honors `NO_COLOR` and `DOTS_NO_COLOR`.
- `lib/ui.sh`: typed-prefix message printers (`ui::info`, `ui::warn`, `ui::error`, `ui::step`, `ui::ok`) with semantic color on prefix and Mocha Text on body; `ui::banner` with Figlet + Mauve color and plain-text fallback.
- `tests/lib/theme.bats`: color emission, `NO_COLOR`, `DOTS_NO_COLOR`, non-TTY tests.
- `tests/lib/ui.bats`: prefix format, stderr routing, color vs no-color, banner fallback tests.
- Makefile `test` target now uses `bats --recursive` to cover subdirectories.

## [0.1.0] — 2026-04-30

### Added
- Repository skeleton: `bin/`, `lib/`, `tests/`, `completions/`, `examples/`, `profiles/` directories.
- `lib/version.sh` exporting `OPENDOTS_VERSION="0.1.0"`.
- `Makefile` with `lint`, `fmt`, `fmt-check`, `test`, `check` targets.
- `.editorconfig` and `.gitattributes` enforcing LF and 2-space indentation on shell files.
- `tests/test_helper.bash` with temp-`$HOME` / temp-`DOTS_DIR` helpers.
- `tests/00_smoke.bats` placeholder smoke test.
- `.githooks/pre-commit` running `make check`.
- GitHub Actions CI matrix (`ubuntu-latest`, `macos-latest`).
- `README.md` skeleton with usage, installation, and development instructions.
