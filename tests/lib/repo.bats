#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/i18n.sh"
  i18n::load "en"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/repo.sh"
  unset DOTS_DIR XDG_CONFIG_HOME
  export HOME
  HOME="$(mktemp -d)"
}

teardown() {
  [[ -n "${HOME:-}" && "$HOME" == /tmp/* ]] && rm -rf "$HOME" || true
  [[ -n "${_extra_dir:-}" && "$_extra_dir" == /tmp/* ]] && rm -rf "$_extra_dir" || true
}

@test "repo::resolve_dir honours dir= in config file when DOTS_DIR is unset" {
  _extra_dir="$(mktemp -d)"
  mkdir -p "${HOME}/.config/opendots"
  printf 'dir=%s\n' "$_extra_dir" >"${HOME}/.config/opendots/config"
  result="$(repo::resolve_dir)"
  [[ "$result" == "$_extra_dir" ]]
}

@test "repo::resolve_dir ignores dir= in config file when path does not exist" {
  mkdir -p "${HOME}/.config/opendots"
  printf 'dir=/nonexistent/path/xyz\n' >"${HOME}/.config/opendots/config"
  mkdir -p "${HOME}/.dotfiles"
  result="$(repo::resolve_dir)"
  [[ "$result" == "${HOME}/.dotfiles" ]]
}

@test "repo::resolve_dir DOTS_DIR env var takes precedence over config file" {
  _extra_dir="$(mktemp -d)"
  local config_dir
  config_dir="$(mktemp -d)"
  mkdir -p "${HOME}/.config/opendots"
  printf 'dir=%s\n' "$config_dir" >"${HOME}/.config/opendots/config"
  DOTS_DIR="$_extra_dir" result="$(repo::resolve_dir)"
  [[ "$result" == "$_extra_dir" ]]
  rm -rf "$config_dir"
}

@test "repo::resolve_dir falls back to ~/.dotfiles when no config and DOTS_DIR unset" {
  mkdir -p "${HOME}/.dotfiles"
  result="$(repo::resolve_dir)"
  [[ "$result" == "${HOME}/.dotfiles" ]]
}
