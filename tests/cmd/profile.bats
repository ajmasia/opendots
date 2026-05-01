#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  mkdir -p "${DFY_DIR}/profiles"
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
}

teardown() {
  teardown_dirs
}

# Helper: create a profile file listing packages (one per line).
make_profile() {
  local name="$1"
  shift
  local profile_file="${DFY_DIR}/profiles/${name}.txt"
  printf '%s\n' "$@" >"$profile_file"
}

@test "install --profile installs exactly the listed packages" {
  make_package vim .vimrc "set nocompatible"
  make_package git .gitconfig "[core]"
  make_profile base vim git
  run "$DOTS_BIN" --profile base install
  [ "$status" -eq 0 ]
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
  assert_symlink "${HOME}/.gitconfig" "${DFY_DIR}/git/.gitconfig"
}

@test "install --profile with missing profile exits 2 and mentions profile name" {
  run "$DOTS_BIN" --profile ghost install
  [ "$status" -eq 2 ]
  [[ "$output" == *"ghost"* ]]
}

@test "install --profile with missing profile lists available profiles" {
  make_profile work vim
  make_profile home git
  run "$DOTS_BIN" --profile nope install
  [ "$status" -eq 2 ]
  [[ "$output" == *"work"* || "$output" == *"home"* ]]
}

@test "--dry-run install --profile creates no symlinks but reports planned set" {
  make_package vim .vimrc
  make_package git .gitconfig
  make_profile base vim git
  run "$DOTS_BIN" --dry-run --profile base install
  [ "$status" -eq 0 ]
  [[ ! -e "${HOME}/.vimrc" ]]
  [[ ! -e "${HOME}/.gitconfig" ]]
}

@test "remove --profile removes exactly the package set" {
  make_package vim .vimrc "set nocompatible"
  make_profile base vim
  "$DOTS_BIN" --profile base install
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
  run "$DOTS_BIN" --profile base remove
  [ "$status" -eq 0 ]
  [[ ! -L "${HOME}/.vimrc" ]]
}

@test "install --profile ignores comment lines and blank lines in profile file" {
  make_package vim .vimrc
  cat >"${DFY_DIR}/profiles/mixed.txt" <<'EOF'
# editor config
vim

# end
EOF
  run "$DOTS_BIN" --profile mixed install
  [ "$status" -eq 0 ]
  assert_symlink "${HOME}/.vimrc" "${DFY_DIR}/vim/.vimrc"
}

@test "status shows active profile name when --profile is used" {
  make_package vim .vimrc
  make_profile base vim
  run "$DOTS_BIN" --profile base status
  [ "$status" -eq 0 ]
  [[ "$output" == *"base"* ]]
}

@test "status shows no active profile when --profile is not used" {
  make_package vim .vimrc
  run "$DOTS_BIN" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"no active profile"* ]]
}
