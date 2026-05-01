# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Source the locale file for <lang>; fall back to en if the file is absent.
# Locale directory is resolved from DFY_LOCALES (if set) or from this file's
# real path so that bin/dfy can be symlinked anywhere.
i18n::load() {
  local lang="${1:-en}"
  local locales_dir
  if [[ -n "${DFY_LOCALES:-}" ]]; then
    locales_dir="$DFY_LOCALES"
  else
    locales_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../locales"
  fi
  local locale_file="${locales_dir}/${lang}.sh"
  if [[ -f "$locale_file" ]]; then
    # shellcheck source=/dev/null
    source "$locale_file"
  else
    local fallback="${locales_dir}/en.sh"
    if [[ -f "$fallback" ]]; then
      # shellcheck source=/dev/null
      source "$fallback"
    fi
  fi
}

# Return the lang code from ~/.config/dotlify/config, or "en" if absent.
i18n::configured_lang() {
  local config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/dotlify/config"
  local lang="en"
  if [[ -f "$config_file" ]]; then
    local line
    line="$(grep -m1 '^lang=' "$config_file" 2>/dev/null || true)"
    if [[ -n "$line" ]]; then
      lang="${line#lang=}"
    fi
  fi
  printf '%s' "$lang"
}
