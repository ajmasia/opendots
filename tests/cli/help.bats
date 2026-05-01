#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
}

@test "dots --help exits 0 and stdout contains usage" {
  run "$DOTS_BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]] || [[ "$output" == *"Uso:"* ]]
}

@test "dots --version exits 0 and stdout contains version" {
  run "$DOTS_BIN" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"0.8.2"* ]]
}

@test "bare dots exits 0 and shows banner" {
  run "$DOTS_BIN"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Dotlify"* ]]
}
