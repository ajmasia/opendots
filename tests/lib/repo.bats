#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/i18n.sh"
  i18n::load "en"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/repo.sh"
  unset DFY_DIR XDG_CONFIG_HOME
  export HOME
  HOME="$(mktemp -d)"
}

teardown() {
  [[ -n "${HOME:-}" && "$HOME" == /tmp/* ]] && rm -rf "$HOME" || true
  [[ -n "${_extra_dir:-}" && "$_extra_dir" == /tmp/* ]] && rm -rf "$_extra_dir" || true
}

@test "repo::resolve_dir honours dir= in config file when DFY_DIR is unset" {
  _extra_dir="$(mktemp -d)"
  mkdir -p "${HOME}/.config/dotlify"
  printf 'dir=%s\n' "$_extra_dir" >"${HOME}/.config/dotlify/config"
  result="$(repo::resolve_dir)"
  [[ "$result" == "$_extra_dir" ]]
}

@test "repo::resolve_dir ignores dir= in config file when path does not exist" {
  mkdir -p "${HOME}/.config/dotlify"
  printf 'dir=/nonexistent/path/xyz\n' >"${HOME}/.config/dotlify/config"
  mkdir -p "${HOME}/.dotfiles"
  result="$(repo::resolve_dir)"
  [[ "$result" == "${HOME}/.dotfiles" ]]
}

@test "repo::resolve_dir DFY_DIR env var takes precedence over config file" {
  _extra_dir="$(mktemp -d)"
  local config_dir
  config_dir="$(mktemp -d)"
  mkdir -p "${HOME}/.config/dotlify"
  printf 'dir=%s\n' "$config_dir" >"${HOME}/.config/dotlify/config"
  DFY_DIR="$_extra_dir" result="$(repo::resolve_dir)"
  [[ "$result" == "$_extra_dir" ]]
  rm -rf "$config_dir"
}

@test "repo::resolve_dir expands leading ~ in dir= config value" {
  mkdir -p "${HOME}/dotfiles-tilde"
  mkdir -p "${HOME}/.config/dotlify"
  printf 'dir=~/dotfiles-tilde\n' >"${HOME}/.config/dotlify/config"
  result="$(repo::resolve_dir)"
  [[ "$result" == "${HOME}/dotfiles-tilde" ]]
}

@test "repo::resolve_dir falls back to ~/.dotfiles when no config and DFY_DIR unset" {
  mkdir -p "${HOME}/.dotfiles"
  result="$(repo::resolve_dir)"
  [[ "$result" == "${HOME}/.dotfiles" ]]
}
