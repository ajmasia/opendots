#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/i18n.sh"
  i18n::load "en"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/repo.sh"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/profile.sh"
  unset DFY_DIR XDG_CONFIG_HOME
  export HOME DFY_DIR
  HOME="$(mktemp -d)"
  DFY_DIR="$(mktemp -d)"
  mkdir -p "${DFY_DIR}/profiles"
}

teardown() {
  [[ -n "${HOME:-}" && "$HOME" == /tmp/* ]] && rm -rf "$HOME" || true
  [[ -n "${DFY_DIR:-}" && "$DFY_DIR" == /tmp/* ]] && rm -rf "$DFY_DIR" || true
}

@test "profile::load strips comments, blank lines, and surrounding whitespace" {
  cat >"${DFY_DIR}/profiles/base.txt" <<'EOF'
# this is a comment
vim
  zsh   # shell config

git
EOF
  result="$(profile::load base)"
  [[ "$result" == $'vim\nzsh\ngit' ]]
}

@test "profile::exists returns 0 for an existing profile" {
  touch "${DFY_DIR}/profiles/base.txt"
  profile::exists base
}

@test "profile::exists returns 1 for a missing profile" {
  run profile::exists missing
  [ "$status" -eq 1 ]
}

@test "profile::load exits 2 with error for a missing profile" {
  run profile::load missing
  [ "$status" -eq 2 ]
  [[ "$output" == *"missing"* ]]
}

@test "profile::load lists available profiles in error output" {
  touch "${DFY_DIR}/profiles/work.txt"
  touch "${DFY_DIR}/profiles/home.txt"
  run profile::load nope
  [ "$status" -eq 2 ]
  [[ "$output" == *"work"* || "$output" == *"home"* ]]
}
