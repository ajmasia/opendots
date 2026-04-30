#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dots"
  export THEME_COLORS_ENABLED=0
}

teardown() {
  teardown_dirs
}

@test "status reports pending conflicts" {
  make_package vim .vimrc
  printf 'existing\n' >"${HOME}/.vimrc"
  run "$DOTS_BIN" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"vim"* ]]
  [[ "$output" == *"onflict"* ]] || [[ "$output" == *"Conflict"* ]]
}

@test "status lists linked packages" {
  make_package vim .vimrc
  stow -d "$DOTS_DIR" -t "$HOME" vim
  run "$DOTS_BIN" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"vim"* ]]
}
