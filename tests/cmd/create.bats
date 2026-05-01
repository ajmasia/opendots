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

@test "create scaffolds package directory and README with --yes" {
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ -d "${DFY_DIR}/mypkg" ]]
  [[ -f "${DFY_DIR}/mypkg/README.md" ]]
  [[ "$(cat "${DFY_DIR}/mypkg/README.md")" == *"# mypkg config"* ]]
}

@test "create README contains TODO placeholder when no description given" {
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ "$(cat "${DFY_DIR}/mypkg/README.md")" == *"TODO: add a description"* ]]
}

@test "create exits 1 when package already exists and has a README" {
  mkdir -p "${DFY_DIR}/existing"
  printf '# existing\n' >"${DFY_DIR}/existing/README.md"
  run "$DOTS_BIN" --yes create existing
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "create adds README when package exists but has none" {
  mkdir -p "${DFY_DIR}/mypkg"
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ -f "${DFY_DIR}/mypkg/README.md" ]]
  [[ "$(cat "${DFY_DIR}/mypkg/README.md")" == *"# mypkg config"* ]]
}

@test "create adds README does not create extra directories" {
  mkdir -p "${DFY_DIR}/mypkg"
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ "$output" == *"README"* ]]
}

@test "create with no args shows usage" {
  run "$DOTS_BIN" create
  [ "$status" -eq 0 ]
  [[ "$output" == *"dfy create"* ]]
}

@test "create --yes skips prompt and uses empty description" {
  run "$DOTS_BIN" --yes create newpkg
  [ "$status" -eq 0 ]
  [[ -f "${DFY_DIR}/newpkg/README.md" ]]
}
