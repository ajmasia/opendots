#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

# Helper: simulate a completion request for the given words.
# The last element is treated as the current word being completed.
_complete() {
  COMPREPLY=()
  COMP_WORDS=("$@")
  COMP_CWORD=$(("${#COMP_WORDS[@]}" - 1))
  _opendots_complete
}

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../test_helper.bash"
  setup_home
  setup_dots_dir
  COMP_WORDS=()
  COMP_CWORD=0
  COMPREPLY=()
  # shellcheck source=completions/opendots.bash
  source "${BATS_TEST_DIRNAME}/../../completions/opendots.bash"
}

teardown() {
  teardown_dirs
}

@test "completes all subcommands at position 1" {
  _complete opendots ""
  [[ " ${COMPREPLY[*]} " == *" install "* ]]
  [[ " ${COMPREPLY[*]} " == *" remove "* ]]
  [[ " ${COMPREPLY[*]} " == *" adopt "* ]]
  [[ " ${COMPREPLY[*]} " == *" list "* ]]
  [[ " ${COMPREPLY[*]} " == *" status "* ]]
  [[ " ${COMPREPLY[*]} " == *" doctor "* ]]
  [[ " ${COMPREPLY[*]} " == *" update "* ]]
  [[ " ${COMPREPLY[*]} " == *" uninstall "* ]]
  [[ " ${COMPREPLY[*]} " == *" help "* ]]
}

@test "filters subcommands by prefix" {
  _complete opendots "in"
  [[ " ${COMPREPLY[*]} " == *" install "* ]]
  [[ " ${COMPREPLY[*]} " != *" remove "* ]]
}

@test "completes global flags when cur starts with -" {
  _complete opendots "--"
  [[ " ${COMPREPLY[*]} " == *" --help "* ]]
  [[ " ${COMPREPLY[*]} " == *" --version "* ]]
  [[ " ${COMPREPLY[*]} " == *" --no-color "* ]]
  [[ " ${COMPREPLY[*]} " == *" --dry-run "* ]]
  [[ " ${COMPREPLY[*]} " == *" --profile "* ]]
  [[ " ${COMPREPLY[*]} " == *" --yes "* ]]
}

@test "completes packages after install" {
  make_package vim .vimrc
  make_package tmux .tmux.conf
  _complete opendots install ""
  [[ " ${COMPREPLY[*]} " == *" vim "* ]]
  [[ " ${COMPREPLY[*]} " == *" tmux "* ]]
}

@test "completes packages after remove" {
  make_package zsh .zshrc
  _complete opendots remove ""
  [[ " ${COMPREPLY[*]} " == *" zsh "* ]]
}

@test "completes packages after adopt" {
  make_package git .gitconfig
  _complete opendots adopt ""
  [[ " ${COMPREPLY[*]} " == *" git "* ]]
}

@test "package completion respects DOTS_DIR override" {
  local other_dir saved
  other_dir="$(mktemp -d)"
  mkdir -p "$other_dir/custom-pkg"
  saved="${DOTS_DIR}"
  DOTS_DIR="$other_dir"
  _complete opendots install ""
  DOTS_DIR="$saved"
  [[ " ${COMPREPLY[*]} " == *" custom-pkg "* ]]
  rm -rf "$other_dir"
}

@test "package completion excludes hidden dirs and profiles/" {
  make_package vim .vimrc
  mkdir -p "${DOTS_DIR}/.git"
  mkdir -p "${DOTS_DIR}/profiles"
  _complete opendots install ""
  [[ " ${COMPREPLY[*]} " == *" vim "* ]]
  [[ " ${COMPREPLY[*]} " != *" .git "* ]]
  [[ " ${COMPREPLY[*]} " != *" profiles "* ]]
}

@test "completes profile names after --profile" {
  mkdir -p "${DOTS_DIR}/profiles"
  printf '' >"${DOTS_DIR}/profiles/work.txt"
  printf '' >"${DOTS_DIR}/profiles/home.txt"
  _complete opendots --profile ""
  [[ " ${COMPREPLY[*]} " == *" work "* ]]
  [[ " ${COMPREPLY[*]} " == *" home "* ]]
  [[ " ${COMPREPLY[*]} " != *".txt"* ]]
}

@test "profile completion respects DOTS_DIR override" {
  local other_dir saved
  other_dir="$(mktemp -d)"
  mkdir -p "$other_dir/profiles"
  printf '' >"$other_dir/profiles/server.txt"
  saved="${DOTS_DIR}"
  DOTS_DIR="$other_dir"
  _complete opendots --profile ""
  DOTS_DIR="$saved"
  [[ " ${COMPREPLY[*]} " == *" server "* ]]
  rm -rf "$other_dir"
}

@test "no package completions for list, status, doctor, or help" {
  make_package vim .vimrc
  _complete opendots list ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
  _complete opendots status ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
  _complete opendots doctor ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
  _complete opendots help ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
}

@test "flags are completed after a subcommand when cur starts with -" {
  _complete opendots install "--"
  [[ " ${COMPREPLY[*]} " == *" --profile "* ]]
  [[ " ${COMPREPLY[*]} " == *" --dry-run "* ]]
}
