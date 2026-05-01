#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
}

teardown() {
  teardown_dirs
}

@test "update: shows nix hint when _DFY_NIX=1" {
  run env _DFY_NIX=1 bash "$DOTS_BIN" update
  [ "$status" -eq 0 ]
  [[ "$output" == *"Nix"* ]]
  [[ "$output" == *"nix profile upgrade dotlify"* ]]
}

@test "uninstall: shows nix hint when _DFY_NIX=1" {
  run env _DFY_NIX=1 bash "$DOTS_BIN" uninstall
  [ "$status" -eq 0 ]
  [[ "$output" == *"Nix"* ]]
  [[ "$output" == *"nix profile remove dotlify"* ]]
}
