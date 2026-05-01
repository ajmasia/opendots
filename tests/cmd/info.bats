#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
  unset EDITOR
}

teardown() {
  teardown_dirs
}

@test "info prints README content when it exists" {
  make_package nvim .config/nvim/init.vim
  printf '# nvim\n\nNeovim configuration\n' >"${DFY_DIR}/nvim/README.md"
  run "$DOTS_BIN" info nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"# nvim"* ]]
  [[ "$output" == *"Neovim configuration"* ]]
}

@test "info prints no-README message when README is absent" {
  make_package vim .vimrc
  run "$DOTS_BIN" info vim
  [ "$status" -eq 0 ]
  [[ "$output" == *"No README found for vim"* ]]
}

@test "info exits 1 when package does not exist" {
  run "$DOTS_BIN" info nonexistent
  [ "$status" -eq 1 ]
}

@test "info with no args shows usage" {
  run "$DOTS_BIN" info
  [ "$status" -eq 0 ]
  [[ "$output" == *"dfy info"* ]]
}

@test "info opens README in EDITOR when set" {
  make_package nvim .config/nvim/init.vim
  printf '# nvim\n\nNeovim config\n' >"${DFY_DIR}/nvim/README.md"
  EDITOR=cat run "$DOTS_BIN" info nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"# nvim"* ]]
}

@test "info falls back to cat when EDITOR is unset" {
  make_package nvim .config/nvim/init.vim
  printf '# nvim\n\nNeovim config\n' >"${DFY_DIR}/nvim/README.md"
  EDITOR="" run "$DOTS_BIN" info nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"# nvim"* ]]
}
