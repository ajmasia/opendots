#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/i18n.sh"
  unset XDG_CONFIG_HOME
}

@test "i18n::load en sources locales/en.sh and MSG_* are defined" {
  i18n::load "en"
  [[ -n "${MSG_USAGE_HINT:-}" ]]
}

@test "i18n::load es sources locales/es.sh and sampled string differs from English" {
  i18n::load "en"
  local en_hint="${MSG_USAGE_HINT}"
  i18n::load "es"
  [[ "${MSG_USAGE_HINT}" != "$en_hint" ]]
}

@test "i18n::load with unknown locale falls back to English without error" {
  i18n::load "xx"
  [[ -n "${MSG_USAGE_HINT:-}" ]]
}

@test "i18n::configured_lang returns es when lang=es is in config" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "${tmpdir}/.config/dotlify"
  printf 'lang=es\n' >"${tmpdir}/.config/dotlify/config"
  local result
  result="$(HOME="$tmpdir" i18n::configured_lang)"
  rm -rf "$tmpdir"
  [[ "$result" == "es" ]]
}

@test "i18n::configured_lang returns en when config file is absent" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  local result
  result="$(HOME="$tmpdir" i18n::configured_lang)"
  rm -rf "$tmpdir"
  [[ "$result" == "en" ]]
}
