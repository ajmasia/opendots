# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
