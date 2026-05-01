# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# True when running on macOS.
os::is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

# True when running from a Nix store path (read-only; no git clone).
# _DFY_NIX=1 can be set in tests to simulate a Nix install.
os::is_nix_store() {
  [[ "${_DFY_NIX:-0}" == "1" ]] || [[ "${DFY_LIB:-}" == /nix/store/* ]]
}

# True when running on Linux.
os::is_linux() { [[ "$(uname -s)" == "Linux" ]]; }

# Resolve canonical path following all symlinks.
# Equivalent to readlink -f on GNU; works on BSD/macOS without extra deps.
os::readlink_f() {
  local src="$1"
  [[ "$src" == /* ]] || src="$PWD/$src"
  local i=0 link
  while [[ -L "$src" && $((i++)) -lt 40 ]]; do
    link="$(readlink "$src")"
    [[ "$link" == /* ]] || link="$(dirname "$src")/$link"
    src="$link"
  done
  if [[ -d "$src" ]]; then
    printf '%s' "$(cd "$src" && pwd -P)"
  else
    printf '%s' "$(cd "$(dirname "$src")" && pwd -P)/$(basename "$src")"
  fi
}

# Return one of: debian ubuntu arch fedora rhel unknown.
# Reads /etc/os-release; falls back to "unknown" on missing file.
os::distro_id() {
  local os_release="/etc/os-release"
  if [[ ! -f "$os_release" ]]; then
    printf 'unknown'
    return
  fi
  local id id_like
  id="$(grep -m1 '^ID=' "$os_release" | cut -d= -f2 | tr -d '"')"
  id_like="$(grep -m1 '^ID_LIKE=' "$os_release" 2>/dev/null | cut -d= -f2 | tr -d '"' || true)"
  case "$id" in
    debian | ubuntu | arch | fedora | rhel)
      printf '%s' "$id"
      ;;
    *)
      case "$id_like" in
        *debian* | *ubuntu*) printf 'debian' ;;
        *arch*) printf 'arch' ;;
        *fedora* | *rhel*) printf 'fedora' ;;
        *) printf 'unknown' ;;
      esac
      ;;
  esac
}
