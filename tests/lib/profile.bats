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
  unset DOTS_DIR XDG_CONFIG_HOME
  export HOME DOTS_DIR
  HOME="$(mktemp -d)"
  DOTS_DIR="$(mktemp -d)"
  mkdir -p "${DOTS_DIR}/profiles"
}

teardown() {
  [[ -n "${HOME:-}" && "$HOME" == /tmp/* ]] && rm -rf "$HOME" || true
  [[ -n "${DOTS_DIR:-}" && "$DOTS_DIR" == /tmp/* ]] && rm -rf "$DOTS_DIR" || true
}

@test "profile::load strips comments, blank lines, and surrounding whitespace" {
  cat >"${DOTS_DIR}/profiles/base.txt" <<'EOF'
# this is a comment
vim
  zsh   # shell config

git
EOF
  result="$(profile::load base)"
  [[ "$result" == $'vim\nzsh\ngit' ]]
}

@test "profile::exists returns 0 for an existing profile" {
  touch "${DOTS_DIR}/profiles/base.txt"
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
  touch "${DOTS_DIR}/profiles/work.txt"
  touch "${DOTS_DIR}/profiles/home.txt"
  run profile::load nope
  [ "$status" -eq 2 ]
  [[ "$output" == *"work"* || "$output" == *"home"* ]]
}
