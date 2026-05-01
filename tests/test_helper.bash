# SPDX-License-Identifier: GPL-3.0-or-later

# Path to the bundled example dotfiles repo (fixture and reference).
# shellcheck disable=SC2034
EXAMPLES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../examples/dotfiles" && pwd)"

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

# Asserts that a symlink at $1 resolves to $2.
assert_symlink() {
  local link="$1" target="$2"
  [[ -L "$link" ]] || {
    echo "not a symlink: $link" >&2
    return 1
  }
  [[ "$(readlink -f "$link")" == "$target" ]] || {
    echo "symlink $link -> $(readlink -f "$link"), expected $target" >&2
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
