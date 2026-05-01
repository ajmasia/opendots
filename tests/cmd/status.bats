#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
}

teardown() {
  teardown_dirs
}

@test "status shows [+] for linked packages" {
  make_package vim .vimrc
  stow -d "$DFY_DIR" -t "$HOME" vim
  run "$DOTS_BIN" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"[+]"*"vim"* ]]
}

@test "status shows [!] and adopt hint for conflicts" {
  make_package vim .vimrc
  printf 'existing\n' >"${HOME}/.vimrc"
  run "$DOTS_BIN" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"[!]"*"vim"* ]]
  [[ "$output" == *"adopt"* ]]
}

@test "status shows [-] for unlinked packages" {
  make_package vim .vimrc
  run "$DOTS_BIN" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"[-]"*"vim"* ]]
}
