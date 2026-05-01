#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
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

@test "global flags accepted after the subcommand" {
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir bash
  run "$DOTS_BIN" list --dir "$DFY_DIR" --no-color
  [ "$status" -eq 0 ]
  teardown_dirs
}

@test "short alias -d sets dotfiles directory" {
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir bash
  run "$DOTS_BIN" -d "$DFY_DIR" list --no-color
  [ "$status" -eq 0 ]
  teardown_dirs
}

@test "short alias -p sets profile" {
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  run "$DOTS_BIN" -d "$DFY_DIR" list -p nonexistent --no-color
  # profile is validated by apply/unlink, not list — just check -p is parsed
  [ "$status" -eq 0 ]
  teardown_dirs
}

@test "short alias -l sets language" {
  run "$DOTS_BIN" -l es --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Subcomandos"* ]] || [[ "$output" == *"subcomand"* ]]
}

@test "-y is accepted as alias for --yes" {
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  run "$DOTS_BIN" -d "$DFY_DIR" -y create testpkg
  [ "$status" -eq 0 ]
  teardown_dirs
}
