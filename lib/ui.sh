# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# User-facing message printers.
# Requires lib/theme.sh to be sourced first.
#
# Format: [prefix] message
#   prefix color  → semantic role (sky, yellow, red, mauve, green)
#   message body  → Mocha Text (#cdd6f4) when colors on; plain when off
#
# error/warn → stderr   info/step/ok/banner → stdout

_ui_print() {
  local stderr="$1" prefix_color="$2" label="$3"
  shift 3
  local line
  line="$(printf '%s%s%s %s%s%s' \
    "$prefix_color" "$label" "$(theme::reset)" \
    "$(theme::text)" "$*" "$(theme::reset)")"
  if [[ "$stderr" == "1" ]]; then
    printf '%s\n' "$line" >&2
  else
    printf '%s\n' "$line"
  fi
}

ui::info() { _ui_print 0 "$(theme::info)" "[info]" "$@"; }
ui::warn() { _ui_print 1 "$(theme::warning)" "[warn]" "$@"; }
ui::error() { _ui_print 1 "$(theme::error)" "[error]" "$@"; }
ui::step() { _ui_print 0 "$(theme::accent)" "[step]" "$@"; }
ui::ok() { _ui_print 0 "$(theme::success)" "[ok]" "$@"; }

ui::banner() {
  local text="$1"
  if command -v figlet >/dev/null 2>&1 && [[ "${THEME_COLORS_ENABLED:-0}" == "1" ]]; then
    printf '%s' "$(theme::accent)"
    figlet -f standard "$text"
    printf '%s' "$(theme::reset)"
  else
    printf '%s\n' "$text"
  fi
}
