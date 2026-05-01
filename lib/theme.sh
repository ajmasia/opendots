# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Catppuccin Mocha palette — 24-bit truecolor escapes.
# Role helpers emit the escape sequence when colors are enabled, nothing otherwise.
# Call theme::supports_color once at startup (bin/dots does this); or set
# THEME_COLORS_ENABLED=1/0 directly before sourcing (useful in tests).

# Returns 0 if stdout is a TTY, NO_COLOR is unset, and --no-color was not passed.
theme::supports_color() {
  [[ -t 1 && -z "${NO_COLOR:-}" && -z "${DFY_NO_COLOR:-}" ]]
}

# Auto-detect on first source; an already-exported value is preserved.
if [[ -z "${THEME_COLORS_ENABLED+x}" ]]; then
  if theme::supports_color; then
    THEME_COLORS_ENABLED=1
  else
    THEME_COLORS_ENABLED=0
  fi
  export THEME_COLORS_ENABLED
fi

theme::accent() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;203;166;247m'; fi
}

theme::text() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;205;214;244m'; fi
}

theme::subtext() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;166;173;200m'; fi
}

theme::success() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;166;227;161m'; fi
}

theme::warning() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;249;226;175m'; fi
}

theme::error() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;243;139;168m'; fi
}

theme::info() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;137;220;235m'; fi
}

theme::muted() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[38;2;108;112;134m'; fi
}

theme::reset() {
  if [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then printf '\033[0m'; fi
}
