# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
