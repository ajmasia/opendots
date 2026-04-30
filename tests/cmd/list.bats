#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/opendots"
  export THEME_COLORS_ENABLED=0
}

teardown() {
  teardown_dirs
}

@test "list reports correct linked/not-linked state" {
  make_package vim .vimrc
  make_package git .gitconfig
  stow -d "$DOTS_DIR" -t "$HOME" vim
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"[ok]"*"vim"* ]]
  [[ "$output" == *"[info]"*"git"* ]]
}

@test "list marks package as conflict when target is a real file" {
  make_package vim .vimrc
  printf 'existing\n' >"${HOME}/.vimrc"
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"[warn]"*"vim"* ]]
}
