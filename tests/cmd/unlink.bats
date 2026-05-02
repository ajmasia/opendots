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

@test "unlink removes a directory-level symlink created by adopt" {
  # Simulate the state after dfy adopt: package has the files, HOME has
  # a directory-level symlink to the package dir.
  mkdir -p "${DFY_DIR}/hyprland/.config/hypr"
  printf 'monitor=,preferred,auto,1\n' >"${DFY_DIR}/hyprland/.config/hypr/hyprland.conf"
  mkdir -p "${HOME}/.config"
  ln -s "${DFY_DIR}/hyprland/.config/hypr" "${HOME}/.config/hypr"
  assert_symlink "${HOME}/.config/hypr" "${DFY_DIR}/hyprland/.config/hypr"
  run "$DOTS_BIN" unlink hyprland
  [ "$status" -eq 0 ]
  [[ ! -L "${HOME}/.config/hypr" ]]
  [[ "$output" == *"remain"* ]]
}

@test "unlink shows no hint when package was not linked" {
  make_package vim .vimrc
  run "$DOTS_BIN" unlink vim
  [ "$status" -eq 0 ]
  [[ "$output" != *"remain"* ]]
}
