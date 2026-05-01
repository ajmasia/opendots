#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  unset XDG_CONFIG_HOME
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
  INIT_DIR="${HOME}/testdots"
}

teardown() {
  teardown_dirs
}

@test "--bare creates git repo without scaffold files" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init --bare
  [ "$status" -eq 0 ]
  [[ -d "${INIT_DIR}/.git" ]]
  [[ ! -f "${INIT_DIR}/bash-aliases/.bash_aliases" ]]
  [[ ! -f "${INIT_DIR}/zsh-aliases/.zsh_aliases" ]]
  [[ ! -f "${INIT_DIR}/vim/.vimrc" ]]
}

@test "default path ~/.dotfiles used when --dir is omitted" {
  run "$DOTS_BIN" init --bare
  [ "$status" -eq 0 ]
  [[ -d "${HOME}/.dotfiles/.git" ]]
}

@test "path exists prompts for alternative; second valid path is used" {
  mkdir -p "$INIT_DIR"
  local alt_dir="${HOME}/altdots"
  run bash -c "printf '%s\n' '${alt_dir}' | \"$DOTS_BIN\" --dir \"$INIT_DIR\" init --bare"
  [ "$status" -eq 0 ]
  [[ -d "${alt_dir}/.git" ]]
}

@test "scaffold files are created with expected content" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init
  [ "$status" -eq 0 ]
  [[ -f "${INIT_DIR}/bash-aliases/.bash_aliases" ]]
  [[ -f "${INIT_DIR}/zsh-aliases/.zsh_aliases" ]]
  [[ -f "${INIT_DIR}/vim/.vimrc" ]]
  [[ -f "${INIT_DIR}/.gitignore" ]]
  grep -q 'alias' "${INIT_DIR}/bash-aliases/.bash_aliases"
  grep -q 'alias' "${INIT_DIR}/zsh-aliases/.zsh_aliases"
  grep -q 'set number' "${INIT_DIR}/vim/.vimrc"
  grep -q '\.DS_Store' "${INIT_DIR}/.gitignore"
}

@test "scaffold creates package READMEs from the package template" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init
  [ "$status" -eq 0 ]
  [[ -f "${INIT_DIR}/bash-aliases/README.md" ]]
  [[ -f "${INIT_DIR}/zsh-aliases/README.md" ]]
  [[ -f "${INIT_DIR}/vim/README.md" ]]
  grep -q '# bash-aliases' "${INIT_DIR}/bash-aliases/README.md"
  grep -q '# zsh-aliases' "${INIT_DIR}/zsh-aliases/README.md"
  grep -q '# vim' "${INIT_DIR}/vim/README.md"
}

@test "init creates repo README.md with usage instructions" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init
  [ "$status" -eq 0 ]
  [[ -f "${INIT_DIR}/README.md" ]]
  grep -q 'dfy apply' "${INIT_DIR}/README.md"
}

@test "scaffold README table uses linked package names" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init
  [ "$status" -eq 0 ]
  grep -q '\[`bash-aliases`\](bash-aliases/README.md)' "${INIT_DIR}/README.md"
  grep -q '\[`vim`\](vim/README.md)' "${INIT_DIR}/README.md"
}

@test "scaffold creates .stow-local-ignore in each package" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init
  [ "$status" -eq 0 ]
  [[ -f "${INIT_DIR}/bash-aliases/.stow-local-ignore" ]]
  [[ -f "${INIT_DIR}/zsh-aliases/.stow-local-ignore" ]]
  [[ -f "${INIT_DIR}/vim/.stow-local-ignore" ]]
  grep -q 'README' "${INIT_DIR}/bash-aliases/.stow-local-ignore"
}

@test "--bare creates repo README.md without scaffold package sections" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init --bare
  [ "$status" -eq 0 ]
  [[ -f "${INIT_DIR}/README.md" ]]
  grep -q 'dfy apply' "${INIT_DIR}/README.md"
  [[ ! -f "${INIT_DIR}/bash-aliases/README.md" ]]
}

@test "--dir after init subcommand is accepted" {
  run "$DOTS_BIN" init --dir "$INIT_DIR" --bare
  [ "$status" -eq 0 ]
  [[ -d "${INIT_DIR}/.git" ]]
}

@test "config contains dir=<path> after successful run" {
  run "$DOTS_BIN" --dir "$INIT_DIR" init --bare
  [ "$status" -eq 0 ]
  local config_file="${HOME}/.config/dotlify/config"
  [[ -f "$config_file" ]]
  grep -q "^dir=${INIT_DIR}$" "$config_file"
}

@test "config::set is not called when git init fails" {
  # Point git to a read-only location that will make git init fail.
  local ro_parent="${HOME}/readonly"
  mkdir -p "$ro_parent"
  chmod 555 "$ro_parent"
  local bad_dir="${ro_parent}/dots"
  run "$DOTS_BIN" --dir "$bad_dir" init --bare
  [ "$status" -ne 0 ]
  local config_file="${HOME}/.config/dotlify/config"
  if [[ -f "$config_file" ]]; then
    ! grep -q "^dir=" "$config_file"
  fi
  chmod 755 "$ro_parent"
}
