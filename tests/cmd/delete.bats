#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
  export DFY_YES=1
}

teardown() {
  teardown_dirs
}

@test "delete <pkg> removes the package directory" {
  make_package vim .vimrc
  run "$DOTS_BIN" delete vim
  [ "$status" -eq 0 ]
  [[ ! -d "${DFY_DIR}/vim" ]]
}

@test "delete <pkg> unlinks first when package is linked" {
  make_package vim .vimrc
  "$DOTS_BIN" link vim
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
  run "$DOTS_BIN" delete vim
  [ "$status" -eq 0 ]
  [[ ! -d "${DFY_DIR}/vim" ]]
  [[ ! -e "${HOME}/.vimrc" ]]
}

@test "delete unknown package exits 1" {
  run "$DOTS_BIN" delete nonexistent
  [ "$status" -eq 1 ]
}

@test "delete with no args shows usage and exits 0" {
  run "$DOTS_BIN" delete
  [ "$status" -eq 0 ]
}

@test "delete profile <name> removes the profile file" {
  mkdir -p "${DFY_DIR}/profiles"
  printf 'vim\n' >"${DFY_DIR}/profiles/work.txt"
  run "$DOTS_BIN" delete profile work
  [ "$status" -eq 0 ]
  [[ ! -f "${DFY_DIR}/profiles/work.txt" ]]
}

@test "delete profile unknown name exits 1" {
  run "$DOTS_BIN" delete profile ghost
  [ "$status" -eq 1 ]
}

@test "delete profile with no name exits 2" {
  run "$DOTS_BIN" delete profile
  [ "$status" -eq 2 ]
}

@test "delete warns when package has uncommitted changes" {
  make_package vim .vimrc
  git -C "$DFY_DIR" init -q
  run "$DOTS_BIN" delete vim
  [ "$status" -eq 0 ]
  [[ "$output" == *"uncommitted"* || "$output" == *"sin commitear"* ]]
}

@test "delete profile warns when profile file has uncommitted changes" {
  mkdir -p "${DFY_DIR}/profiles"
  printf 'vim\n' >"${DFY_DIR}/profiles/work.txt"
  git -C "$DFY_DIR" init -q
  run "$DOTS_BIN" delete profile work
  [ "$status" -eq 0 ]
  [[ "$output" == *"uncommitted"* || "$output" == *"sin commitear"* ]]
}
