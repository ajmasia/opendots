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

@test "adopt <pkg> moves real file into package and creates symlink without content change" {
  # Package defines .vimrc as the file to adopt
  make_package vim .vimrc "from-package"
  # Real file exists in HOME with different content
  printf 'my real vimrc\n' >"${HOME}/.vimrc"
  run "$DOTS_BIN" --yes adopt vim
  [ "$status" -eq 0 ]
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
  [[ "$(cat "${DFY_DIR}/vim/.vimrc")" == "my real vimrc" ]]
}

@test "adopt <pkg> aborts with exit 1 when user rejects the prompt" {
  make_package vim .vimrc
  printf 'existing\n' >"${HOME}/.vimrc"
  run bash -c "printf 'n\n' | \"${DOTS_BIN}\" adopt vim"
  [ "$status" -eq 1 ]
  [[ ! -L "${HOME}/.vimrc" ]]
}

@test "adopt <pkg> succeeds non-interactively with --yes" {
  make_package vim .vimrc
  printf 'existing\n' >"${HOME}/.vimrc"
  run "$DOTS_BIN" --yes adopt vim
  [ "$status" -eq 0 ]
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
}
