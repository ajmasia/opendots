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
  local version_file="${BATS_TEST_DIRNAME}/../../lib/version.sh"
  local expected_version
  expected_version="$(grep -m1 'DOTLIFY_VERSION=' "$version_file" | cut -d'"' -f2)"
  run "$DOTS_BIN" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"$expected_version"* ]]
}

@test "bare dots exits 0 and shows banner" {
  run "$DOTS_BIN"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Dotlify"* ]]
}

@test "dfy create --help shows create-specific usage with -s flag" {
  run "$DOTS_BIN" create --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"create"* ]]
  [[ "$output" == *"subdir"* ]]
}

@test "dfy link --help shows link-specific usage with --profile" {
  run "$DOTS_BIN" link --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"link"* ]]
  [[ "$output" == *"profile"* ]]
}

@test "dfy init --help shows init-specific usage with --bare" {
  run "$DOTS_BIN" init --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"init"* ]]
  [[ "$output" == *"bare"* ]]
}

@test "dfy --help with subcommand shows subcommand help, not global help" {
  run "$DOTS_BIN" create --help
  [ "$status" -eq 0 ]
  [[ "$output" != *"Subcommands:"* ]]
  [[ "$output" != *"Subcomandos:"* ]]
}

@test "dfy help create shows create-specific help" {
  run "$DOTS_BIN" help create
  [ "$status" -eq 0 ]
  [[ "$output" == *"create"* ]]
  [[ "$output" == *"subdir"* ]]
}
