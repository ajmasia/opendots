# SPDX-License-Identifier: GPL-3.0-or-later

# Creates a temporary DOTS_DIR with optional package skeletons.
# Usage: setup_dots_dir [pkg...]
setup_dots_dir() {
  export DOTS_DIR
  DOTS_DIR="$(mktemp -d)"
  for pkg in "$@"; do
    mkdir -p "${DOTS_DIR}/${pkg}"
  done
}

# Creates a temporary HOME directory and overrides HOME.
setup_home() {
  export HOME
  HOME="$(mktemp -d)"
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
  [[ -n "${DOTS_DIR:-}" && "$DOTS_DIR" == /tmp/* ]] && rm -rf "$DOTS_DIR"
  [[ -n "${HOME:-}" && "$HOME" == /tmp/* ]] && rm -rf "$HOME"
}
