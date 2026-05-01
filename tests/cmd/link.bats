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

@test "link <pkg> creates the expected symlinks" {
  make_package vim .vimrc "set nocompatible"
  run "$DOTS_BIN" link vim
  [ "$status" -eq 0 ]
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
}

@test "link <pkg> aborts with exit 3 when a target file is real" {
  make_package vim .vimrc
  printf 'existing\n' >"${HOME}/.vimrc"
  run "$DOTS_BIN" link vim
  [ "$status" -eq 3 ]
  [[ "$output" == *".vimrc"* ]]
}

@test "link with no args exits 2 with usage hint" {
  run "$DOTS_BIN" link
  [ "$status" -eq 2 ]
}

@test "--dry-run link creates no symlinks" {
  make_package vim .vimrc
  run "$DOTS_BIN" --dry-run link vim
  [ "$status" -eq 0 ]
  [[ ! -e "${HOME}/.vimrc" ]]
}

@test "--dry-run link reports conflict and exits 3 when target is real" {
  make_package vim .vimrc
  printf 'existing\n' >"${HOME}/.vimrc"
  run "$DOTS_BIN" --dry-run link vim
  [ "$status" -eq 3 ]
  [[ ! -L "${HOME}/.vimrc" ]]
}
