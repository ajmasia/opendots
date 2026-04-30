#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/opendots"
  export THEME_COLORS_ENABLED=0
}

@test "unknown subcommand exits 2 and output mentions usage" {
  run "$DOTS_BIN" foobar
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage"* ]] || [[ "$output" == *"--help"* ]]
}

@test "unknown flag exits 2" {
  run "$DOTS_BIN" --foobar
  [ "$status" -eq 2 ]
}

@test "--no-color flag produces output without escape sequences" {
  run "$DOTS_BIN" --no-color --help
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\033['* ]]
}
