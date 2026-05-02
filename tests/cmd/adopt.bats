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

@test "adopt moves files from HOME dir that mirrors an empty package directory" {
  # Package has only an empty directory scaffold (no files yet)
  mkdir -p "${DFY_DIR}/hyprland/.config/hypr"
  # Real config exists in HOME
  mkdir -p "${HOME}/.config/hypr"
  printf 'monitor=,preferred,auto,1\n' >"${HOME}/.config/hypr/hyprland.conf"
  run "$DOTS_BIN" --yes adopt hyprland
  [ "$status" -eq 0 ]
  # File moved into package
  [[ -f "${DFY_DIR}/hyprland/.config/hypr/hyprland.conf" ]]
  # HOME path now a symlink into the package
  assert_symlink "${HOME}/.config/hypr/hyprland.conf" "${DFY_DIR}/hyprland/.config/hypr/hyprland.conf"
}

@test "adopt recurses into subdirectories of the HOME mirror dir" {
  mkdir -p "${DFY_DIR}/hyprland/.config/hypr"
  mkdir -p "${HOME}/.config/hypr/rules"
  printf 'monitor=,preferred,auto,1\n' >"${HOME}/.config/hypr/hyprland.conf"
  printf 'windowrule=float,pavucontrol\n' >"${HOME}/.config/hypr/rules/windows.conf"
  run "$DOTS_BIN" --yes adopt hyprland
  [ "$status" -eq 0 ]
  [[ -f "${DFY_DIR}/hyprland/.config/hypr/hyprland.conf" ]]
  [[ -f "${DFY_DIR}/hyprland/.config/hypr/rules/windows.conf" ]]
  assert_symlink "${HOME}/.config/hypr/hyprland.conf" "${DFY_DIR}/hyprland/.config/hypr/hyprland.conf"
  assert_symlink "${HOME}/.config/hypr/rules/windows.conf" "${DFY_DIR}/hyprland/.config/hypr/rules/windows.conf"
}
