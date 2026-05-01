#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
  export THEME_COLORS_ENABLED=0
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/ui.sh"
}

# --- plain-text (no color) output format ---

@test "ui::info outputs [i] prefix and message" {
  result="$(ui::info "hello world")"
  [[ "$result" == "[i] hello world" ]]
}

@test "ui::warn outputs [!] prefix and message" {
  result="$(ui::warn "something off" 2>&1)"
  [[ "$result" == "[!] something off" ]]
}

@test "ui::error outputs [x] prefix and message" {
  result="$(ui::error "bad thing" 2>&1)"
  [[ "$result" == "[x] bad thing" ]]
}

@test "ui::step outputs [>] prefix and message" {
  result="$(ui::step "doing something")"
  [[ "$result" == "[>] doing something" ]]
}

@test "ui::ok outputs [+] prefix and message" {
  result="$(ui::ok "all done")"
  [[ "$result" == "[+] all done" ]]
}

# --- routing: error/warn to stderr, others to stdout ---

@test "ui::error writes to stderr, not stdout" {
  stdout="$(ui::error "oops")"
  [[ -z "$stdout" ]]
}

@test "ui::warn writes to stderr, not stdout" {
  stdout="$(ui::warn "heads up")"
  [[ -z "$stdout" ]]
}

@test "ui::error does not change exit code" {
  ui::error "ignored"
  [[ $? -eq 0 ]]
}

# --- color output ---

@test "ui::info with colors: output contains escape sequences" {
  export THEME_COLORS_ENABLED=1
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/ui.sh"
  result="$(ui::info "hello")"
  [[ "$result" == *$'\033['* ]]
  [[ "$result" == *"[i]"* ]]
  [[ "$result" == *"hello"* ]]
}

@test "ui::info with NO_COLOR: plain text, no escape sequences" {
  export NO_COLOR=1
  unset THEME_COLORS_ENABLED
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/ui.sh"
  result="$(ui::info "hello")"
  [[ "$result" == "[i] hello" ]]
  [[ "$result" != *$'\033['* ]]
}

# --- banner ---

@test "ui::banner falls back to plain text when figlet is absent" {
  tmpdir="$(mktemp -d)"
  result="$(PATH="$tmpdir" ui::banner "Dotlify")"
  rm -rf "$tmpdir"
  [[ "$result" == "Dotlify" ]]
}

@test "ui::banner prints plain text when colors are off regardless of figlet" {
  result="$(ui::banner "Dotlify")"
  [[ "$result" == "Dotlify" ]]
}
