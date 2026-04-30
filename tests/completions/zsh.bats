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

@test "zsh: _opendots_list_packages returns packages from DOTS_DIR" {
  make_package vim .vimrc
  make_package tmux .tmux.conf
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../../completions/_opendots'
    _opendots_list_packages '${DOTS_DIR}'
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"vim"* ]]
  [[ "$output" == *"tmux"* ]]
}

@test "zsh: _opendots_list_packages excludes profiles/ and hidden dirs" {
  make_package vim .vimrc
  mkdir -p "${DOTS_DIR}/profiles"
  mkdir -p "${DOTS_DIR}/.git"
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../../completions/_opendots'
    _opendots_list_packages '${DOTS_DIR}'
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"vim"* ]]
  [[ "$output" != *"profiles"* ]]
  [[ "$output" != *".git"* ]]
}

@test "zsh: _opendots_list_profiles returns profile names without .txt" {
  mkdir -p "${DOTS_DIR}/profiles"
  printf '' >"${DOTS_DIR}/profiles/work.txt"
  printf '' >"${DOTS_DIR}/profiles/home.txt"
  run zsh -c "
    source '${BATS_TEST_DIRNAME}/../../completions/_opendots'
    _opendots_list_profiles '${DOTS_DIR}'
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"work"* ]]
  [[ "$output" == *"home"* ]]
  [[ "$output" != *".txt"* ]]
}

@test "zsh: _opendots_resolve_dir returns DOTS_DIR when set" {
  run zsh -c "
    DOTS_DIR='${DOTS_DIR}'
    source '${BATS_TEST_DIRNAME}/../../completions/_opendots'
    _opendots_resolve_dir
  "
  [ "$status" -eq 0 ]
  [[ "$output" == "$DOTS_DIR" ]]
}

@test "zsh: _opendots_resolve_dir reads dir= from config file" {
  local config_dir="${HOME}/.config/opendots"
  mkdir -p "$config_dir"
  printf 'dir=%s\n' "${DOTS_DIR}" >"${config_dir}/config"
  run zsh -c "
    unset DOTS_DIR XDG_CONFIG_HOME
    HOME='${HOME}'
    source '${BATS_TEST_DIRNAME}/../../completions/_opendots'
    _opendots_resolve_dir
  "
  [ "$status" -eq 0 ]
  [[ "$output" == "$DOTS_DIR" ]]
}
