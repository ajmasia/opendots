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

@test "unlink <pkg> removes only that package's symlinks" {
  make_package vim .vimrc
  stow -d "$DFY_DIR" -t "$HOME" vim
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
  run "$DOTS_BIN" unlink vim
  [ "$status" -eq 0 ]
  [[ ! -e "${HOME}/.vimrc" ]]
}

@test "unlink <pkg> is a silent no-op (exit 0) when not currently linked" {
  make_package vim .vimrc
  run "$DOTS_BIN" unlink vim
  [ "$status" -eq 0 ]
}

@test "unlink informs user that package files remain in the repository" {
  make_package vim .vimrc
  stow -d "$DFY_DIR" -t "$HOME" vim
  run "$DOTS_BIN" unlink vim
  [ "$status" -eq 0 ]
  [[ "$output" == *"remain"* ]]
  [[ -f "${DFY_DIR}/vim/.vimrc" ]]
}
