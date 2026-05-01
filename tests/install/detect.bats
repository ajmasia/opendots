#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=install.sh
  source "${BATS_TEST_DIRNAME}/../../install.sh"
  FIXTURE_DIR="${BATS_TEST_TMPDIR}/fixtures"
  mkdir -p "$FIXTURE_DIR"
}

# Wrapper so bats `run` can call install::pkg_manager with a custom uname.
_pkg_manager_darwin() { _INSTALL_UNAME="Darwin" install::pkg_manager; }

# Write an os-release fixture and return its path.
_fixture() {
  local id="${1}" id_like="${2:-}"
  local f="${FIXTURE_DIR}/os-release-${id}"
  printf 'ID=%s\n' "$id" >"$f"
  [[ -n "$id_like" ]] && printf 'ID_LIKE=%s\n' "$id_like" >>"$f"
  printf '%s' "$f"
}

# Wrapper so bats `run` can call install::pkg_manager with a custom os-release.
_pkg_manager_for() { _OS_RELEASE="${1}" install::pkg_manager; }

@test "macOS (Darwin) -> brew" {
  run _pkg_manager_darwin
  [ "$status" -eq 0 ]
  [ "$output" = "brew" ]
}

@test "ubuntu -> apt" {
  run _pkg_manager_for "$(_fixture ubuntu)"
  [ "$status" -eq 0 ]
  [ "$output" = "apt" ]
}

@test "debian -> apt" {
  run _pkg_manager_for "$(_fixture debian)"
  [ "$status" -eq 0 ]
  [ "$output" = "apt" ]
}

@test "arch -> pacman" {
  run _pkg_manager_for "$(_fixture arch)"
  [ "$status" -eq 0 ]
  [ "$output" = "pacman" ]
}

@test "manjaro (ID_LIKE=arch) -> pacman" {
  run _pkg_manager_for "$(_fixture manjaro arch)"
  [ "$status" -eq 0 ]
  [ "$output" = "pacman" ]
}

@test "fedora -> dnf" {
  run _pkg_manager_for "$(_fixture fedora)"
  [ "$status" -eq 0 ]
  [ "$output" = "dnf" ]
}

@test "rocky (ID_LIKE=rhel) -> dnf" {
  run _pkg_manager_for "$(_fixture rocky rhel)"
  [ "$status" -eq 0 ]
  [ "$output" = "dnf" ]
}

@test "alpine (unknown) -> unknown" {
  run _pkg_manager_for "$(_fixture alpine)"
  [ "$status" -eq 0 ]
  [ "$output" = "unknown" ]
}
