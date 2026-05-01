# SPDX-License-Identifier: GPL-3.0-or-later

# Creates a temporary DFY_DIR with optional package skeletons.
# Usage: setup_dots_dir [pkg...]
setup_dots_dir() {
  export DFY_DIR
  DFY_DIR="$(mktemp -d)"
  DFY_DIR="$(cd "$DFY_DIR" && pwd -P)"
  for pkg in "$@"; do
    mkdir -p "${DFY_DIR}/${pkg}"
  done
}

# Creates a temporary HOME directory and overrides HOME.
setup_home() {
  export HOME
  HOME="$(mktemp -d)"
  HOME="$(cd "$HOME" && pwd -P)"
}

# Create a package <pkg> with a single file <relpath> containing <content>.
# Usage: make_package <pkg> <relpath> [content]
make_package() {
  local pkg="$1" relpath="$2" content="${3:-# placeholder}"
  mkdir -p "${DFY_DIR}/${pkg}/$(dirname "$relpath")"
  printf '%s\n' "$content" >"${DFY_DIR}/${pkg}/${relpath}"
}

# Portable readlink -f (follows all symlinks; works on GNU and BSD/macOS).
_readlink_f() {
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

# Asserts that a symlink at $1 resolves to $2.
assert_symlink() {
  local link="$1" target="$2"
  [[ -L "$link" ]] || {
    echo "not a symlink: $link" >&2
    return 1
  }
  local resolved
  resolved="$(_readlink_f "$link")"
  [[ "$resolved" == "$target" ]] || {
    echo "symlink $link -> $resolved, expected $target" >&2
    return 1
  }
}

# Tears down temp directories created by setup_dots_dir / setup_home.
teardown_dirs() {
  local sys_tmp
  sys_tmp="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
  [[ -n "${DFY_DIR:-}" && "$DFY_DIR" == "${sys_tmp}"/* ]] && rm -rf "$DFY_DIR"
  [[ -n "${HOME:-}" && "$HOME" == "${sys_tmp}"/* ]] && rm -rf "$HOME"
  return 0
}
