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

@test "list shows description when README has prose" {
  make_package nvim .config/nvim/init.vim
  printf '# nvim\n\nNeovim configuration\n' >"${DFY_DIR}/nvim/README.md"
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"nvim"* ]]
  [[ "$output" == *"Neovim configuration"* ]]
}

@test "list shows no description column for package without README" {
  make_package zsh .zshrc
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"- zsh"* ]]
  [[ "$output" != *"(no description)"* ]]
}

@test "list aligns descriptions to a consistent column" {
  make_package nvim .config/nvim/init.vim
  make_package tmux .tmux.conf
  printf '# nvim\n\nNeovim configuration\n' >"${DFY_DIR}/nvim/README.md"
  printf '# tmux\n\nTerminal multiplexer\n' >"${DFY_DIR}/tmux/README.md"
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  local nvim_line tmux_line nvim_col tmux_col
  nvim_line="$(printf '%s\n' "$output" | grep 'nvim')"
  tmux_line="$(printf '%s\n' "$output" | grep 'tmux')"
  nvim_col="${nvim_line%%Neovim*}"
  tmux_col="${tmux_line%%Terminal*}"
  [[ "${#nvim_col}" -eq "${#tmux_col}" ]]
}
