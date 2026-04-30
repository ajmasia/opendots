#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/opendots"
  export THEME_COLORS_ENABLED=0
}

teardown() {
  teardown_dirs
}

@test "doctor reports broken symlinks pointing into DOTS_DIR" {
  make_package vim .vimrc
  stow -d "$DOTS_DIR" -t "$HOME" vim
  # Break the symlink by removing the package file
  rm "${DOTS_DIR}/vim/.vimrc"
  run "$DOTS_BIN" doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *".vimrc"* ]]
}

@test "doctor warns when stow < 2.3.1" {
  local mock_dir
  mock_dir="$(mktemp -d)"
  cat >"${mock_dir}/stow" <<'MOCK'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  printf 'stow (GNU Stow) version 2.2.0\n'
  exit 0
fi
exec stow "$@"
MOCK
  chmod +x "${mock_dir}/stow"
  run env PATH="${mock_dir}:${PATH}" "$DOTS_BIN" doctor
  rm -rf "$mock_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2.2.0"* ]] || [[ "$output" == *"stow"* ]]
}

@test "doctor reports ok when everything is fine" {
  run "$DOTS_BIN" doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok"* ]] || [[ "$output" == *"good"* ]] || [[ "$output" == *"orden"* ]]
}
