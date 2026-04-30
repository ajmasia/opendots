#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/opendots"
  export THEME_COLORS_ENABLED=0
}

@test "dots --lang es --help stdout is in Spanish" {
  run "$DOTS_BIN" --lang es --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Subcomandos:"* ]]
}

@test "dots --lang xx --help stdout is in English (fallback)" {
  run "$DOTS_BIN" --lang xx --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Subcommands:"* ]]
}
