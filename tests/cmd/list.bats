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

@test "list shows package names with - prefix" {
  make_package vim .vimrc
  make_package git .gitconfig
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"- vim"* ]]
  [[ "$output" == *"- git"* ]]
}

@test "list does not show link status indicators" {
  make_package vim .vimrc
  stow -d "$DFY_DIR" -t "$HOME" vim
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" != *"[+]"* ]]
  [[ "$output" != *"[!]"* ]]
}
