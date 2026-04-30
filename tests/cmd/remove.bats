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

@test "remove <pkg> removes only that package's symlinks" {
  make_package vim .vimrc
  stow -d "$DOTS_DIR" -t "$HOME" vim
  assert_symlink "${HOME}/.vimrc" "${DOTS_DIR}/vim/.vimrc"
  run "$DOTS_BIN" remove vim
  [ "$status" -eq 0 ]
  [[ ! -e "${HOME}/.vimrc" ]]
}

@test "remove <pkg> is a silent no-op (exit 0) when not currently linked" {
  make_package vim .vimrc
  run "$DOTS_BIN" remove vim
  [ "$status" -eq 0 ]
}
