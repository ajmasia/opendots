#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../test_helper.bash"
  setup_home
  setup_dots_dir
  if ! command -v zsh &>/dev/null; then
    skip "zsh not in PATH"
  fi
}

teardown() {
  teardown_dirs
}

@test "zsh: _dfy_list_packages returns packages from DFY_DIR" {
  make_package vim .vimrc
  make_package tmux .tmux.conf
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../../completions/_dfy'
    _dfy_list_packages '${DFY_DIR}'
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"vim"* ]]
  [[ "$output" == *"tmux"* ]]
}

@test "zsh: _dfy_list_packages excludes profiles/ and hidden dirs" {
  make_package vim .vimrc
  mkdir -p "${DFY_DIR}/profiles"
  mkdir -p "${DFY_DIR}/.git"
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../../completions/_dfy'
    _dfy_list_packages '${DFY_DIR}'
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"vim"* ]]
  [[ "$output" != *"profiles"* ]]
  [[ "$output" != *".git"* ]]
}

@test "zsh: _dfy_list_profiles returns profile names without .txt" {
  mkdir -p "${DFY_DIR}/profiles"
  printf '' >"${DFY_DIR}/profiles/work.txt"
  printf '' >"${DFY_DIR}/profiles/home.txt"
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../../completions/_dfy'
    _dfy_list_profiles '${DFY_DIR}'
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"work"* ]]
  [[ "$output" == *"home"* ]]
  [[ "$output" != *".txt"* ]]
}

@test "zsh: _dfy_resolve_dir returns DFY_DIR when set" {
  run zsh -c "
    DFY_DIR='${DFY_DIR}'
    source '${BATS_TEST_DIRNAME}/../../completions/_dfy'
    _dfy_resolve_dir
  "
  [ "$status" -eq 0 ]
  [[ "$output" == "$DFY_DIR" ]]
}

@test "zsh: _dfy_resolve_dir reads dir= from config file" {
  local config_dir="${HOME}/.config/dotlify"
  mkdir -p "$config_dir"
  printf 'dir=%s\n' "${DFY_DIR}" >"${config_dir}/config"
  run zsh -c "
    unset DFY_DIR XDG_CONFIG_HOME
    HOME='${HOME}'
    source '${BATS_TEST_DIRNAME}/../../completions/_dfy'
    _dfy_resolve_dir
  "
  [ "$status" -eq 0 ]
  [[ "$output" == "$DFY_DIR" ]]
}
