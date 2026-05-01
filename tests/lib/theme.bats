#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
}

@test "theme: emits truecolor escape when THEME_COLORS_ENABLED=1" {
  export THEME_COLORS_ENABLED=1
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  result="$(theme::accent)"
  [[ "$result" == *$'\033['* ]]
}

@test "theme: all role helpers emit empty string when THEME_COLORS_ENABLED=0" {
  export THEME_COLORS_ENABLED=0
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  for fn in theme::accent theme::text theme::subtext theme::success \
    theme::warning theme::error theme::info theme::reset; do
    result="$($fn)"
    [[ -z "$result" ]] || { echo "$fn emitted non-empty output with colors off" >&2; return 1; }
  done
}

@test "theme: no escapes when NO_COLOR is set" {
  export NO_COLOR=1
  unset THEME_COLORS_ENABLED
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  [[ "${THEME_COLORS_ENABLED}" == "0" ]]
  result="$(theme::accent)"
  [[ -z "$result" ]]
}

@test "theme: no escapes when DFY_NO_COLOR is set" {
  export DFY_NO_COLOR=1
  unset NO_COLOR
  unset THEME_COLORS_ENABLED
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  [[ "${THEME_COLORS_ENABLED}" == "0" ]]
  result="$(theme::accent)"
  [[ -z "$result" ]]
}

@test "theme: no escapes in non-TTY context (stdout is piped in bats)" {
  unset THEME_COLORS_ENABLED
  unset NO_COLOR
  unset DFY_NO_COLOR
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  # bats runs tests with stdout piped, so theme::supports_color returns 1
  [[ "${THEME_COLORS_ENABLED}" == "0" ]]
  result="$(theme::accent)"
  [[ -z "$result" ]]
}
