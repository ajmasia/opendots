#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

# Helper: simulate a completion request for the given words.
# The last element is treated as the current word being completed.
_complete() {
  COMPREPLY=()
  COMP_WORDS=("$@")
  COMP_CWORD=$(("${#COMP_WORDS[@]}" - 1))
  _dfy_complete
}

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../test_helper.bash"
  setup_home
  setup_dots_dir
  COMP_WORDS=()
  COMP_CWORD=0
  COMPREPLY=()
  # shellcheck source=completions/dfy.bash
  source "${BATS_TEST_DIRNAME}/../../completions/dfy.bash"
}

teardown() {
  teardown_dirs
}

@test "completes all subcommands at position 1" {
  _complete dfy ""
  [[ " ${COMPREPLY[*]} " == *" link "* ]]
  [[ " ${COMPREPLY[*]} " == *" unlink "* ]]
  [[ " ${COMPREPLY[*]} " == *" adopt "* ]]
  [[ " ${COMPREPLY[*]} " == *" list "* ]]
  [[ " ${COMPREPLY[*]} " == *" status "* ]]
  [[ " ${COMPREPLY[*]} " == *" doctor "* ]]
  [[ " ${COMPREPLY[*]} " == *" update "* ]]
  [[ " ${COMPREPLY[*]} " == *" uninstall "* ]]
  [[ " ${COMPREPLY[*]} " == *" help "* ]]
}

@test "filters subcommands by prefix" {
  _complete dfy "li"
  [[ " ${COMPREPLY[*]} " == *" link "* ]]
  [[ " ${COMPREPLY[*]} " != *" unlink "* ]]
}

@test "completes global flags when cur starts with -" {
  _complete dfy "--"
  [[ " ${COMPREPLY[*]} " == *" --help "* ]]
  [[ " ${COMPREPLY[*]} " == *" --version "* ]]
  [[ " ${COMPREPLY[*]} " == *" --no-color "* ]]
  [[ " ${COMPREPLY[*]} " == *" --dry-run "* ]]
  [[ " ${COMPREPLY[*]} " == *" --profile "* ]]
  [[ " ${COMPREPLY[*]} " == *" --yes "* ]]
}

@test "completes packages after link" {
  make_package vim .vimrc
  make_package tmux .tmux.conf
  _complete dfy link ""
  [[ " ${COMPREPLY[*]} " == *" vim "* ]]
  [[ " ${COMPREPLY[*]} " == *" tmux "* ]]
}

@test "completes packages after unlink" {
  make_package zsh .zshrc
  _complete dfy unlink ""
  [[ " ${COMPREPLY[*]} " == *" zsh "* ]]
}

@test "completes packages after adopt" {
  make_package git .gitconfig
  _complete dfy adopt ""
  [[ " ${COMPREPLY[*]} " == *" git "* ]]
}

@test "package completion respects DFY_DIR override" {
  local other_dir saved
  other_dir="$(mktemp -d)"
  mkdir -p "$other_dir/custom-pkg"
  saved="${DFY_DIR}"
  DFY_DIR="$other_dir"
  _complete dfy link ""
  DFY_DIR="$saved"
  [[ " ${COMPREPLY[*]} " == *" custom-pkg "* ]]
  rm -rf "$other_dir"
}

@test "package completion excludes hidden dirs and profiles/" {
  make_package vim .vimrc
  mkdir -p "${DFY_DIR}/.git"
  mkdir -p "${DFY_DIR}/profiles"
  _complete dfy link ""
  [[ " ${COMPREPLY[*]} " == *" vim "* ]]
  [[ " ${COMPREPLY[*]} " != *" .git "* ]]
  [[ " ${COMPREPLY[*]} " != *" profiles "* ]]
}

@test "completes profile names after --profile" {
  mkdir -p "${DFY_DIR}/profiles"
  printf '' >"${DFY_DIR}/profiles/work.txt"
  printf '' >"${DFY_DIR}/profiles/home.txt"
  _complete dfy --profile ""
  [[ " ${COMPREPLY[*]} " == *" work "* ]]
  [[ " ${COMPREPLY[*]} " == *" home "* ]]
  [[ " ${COMPREPLY[*]} " != *".txt"* ]]
}

@test "profile completion respects DFY_DIR override" {
  local other_dir saved
  other_dir="$(mktemp -d)"
  mkdir -p "$other_dir/profiles"
  printf '' >"$other_dir/profiles/server.txt"
  saved="${DFY_DIR}"
  DFY_DIR="$other_dir"
  _complete dfy --profile ""
  DFY_DIR="$saved"
  [[ " ${COMPREPLY[*]} " == *" server "* ]]
  rm -rf "$other_dir"
}

@test "no package completions for list, status, doctor, or help" {
  make_package vim .vimrc
  _complete dfy list ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
  _complete dfy status ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
  _complete dfy doctor ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
  _complete dfy help ""
  [[ ${#COMPREPLY[@]} -eq 0 ]]
}

@test "flags are completed after a subcommand when cur starts with -" {
  _complete dfy link "--"
  [[ " ${COMPREPLY[*]} " == *" --profile "* ]]
  [[ " ${COMPREPLY[*]} " == *" --dry-run "* ]]
}
