# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Resolve the dotfiles directory with precedence:
#   --dir flag (DFY_DIR set by args parser) > DFY_DIR env var >
#   dir= in ~/.config/dotlify/config > ~/.dotfiles
# Prints the resolved path; aborts with exit 1 if not found.
repo::resolve_dir() {
  local dir="${DFY_DIR:-}"
  if [[ -z "$dir" ]]; then
    local config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/dotlify/config"
    if [[ -f "$config_file" ]]; then
      local line
      line="$(grep -m1 '^dir=' "$config_file" 2>/dev/null || true)"
      if [[ -n "$line" ]]; then
        local candidate="${line#dir=}"
        candidate="${candidate/#\~/$HOME}"
        if [[ -d "$candidate" ]]; then
          dir="$candidate"
        fi
      fi
    fi
  fi
  dir="${dir:-${HOME}/.dotfiles}"
  if [[ ! -d "$dir" ]]; then
    # shellcheck disable=SC2059
    printf "${MSG_REPO_NOT_FOUND:-Dotfiles directory not found: %s}\n" "$dir" >&2
    printf '%s\n' "${MSG_REPO_HINT:-Create it, set DFY_DIR, or pass --dir <path>.}" >&2
    exit 1
  fi
  printf '%s' "$dir"
}

# List top-level package directories inside <dots_dir>.
# Excludes hidden dirs (.git, .stow-local-ignore, etc.) and the profiles/ dir.
repo::list_packages() {
  local dir="$1"
  local entry name
  while IFS= read -r -d '' entry; do
    name="$(basename "$entry")"
    [[ "$name" == profiles || "$name" == .* ]] && continue
    printf '%s\n' "$name"
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
}

# Extract a one-line description from <dots_dir>/<pkg>/README.md.
# Returns the first meaningful prose line: skips the leading # Title heading,
# then returns the first non-empty, non-heading line.
# Falls back to the title heading text if no prose line is found.
# Prints "(no description)" when the README exists but is completely empty.
# Prints nothing (returns 0) when no README exists.
repo::pkg_description() {
  local dots_dir="$1" pkg="$2"
  local readme="${dots_dir}/${pkg}/README.md"
  [[ -f "$readme" ]] || return 0

  local line heading="" h skipped_heading=0

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    if [[ "$skipped_heading" -eq 0 ]]; then
      if [[ "$line" == "#"* ]]; then
        h="$line"
        while [[ "$h" == "#"* ]]; do h="${h#\#}"; done
        h="${h# }"
        heading="$h"
        skipped_heading=1
        continue
      else
        printf '%s' "$line"
        return 0
      fi
    fi

    if [[ "$line" != "#"* ]]; then
      printf '%s' "$line"
      return 0
    fi
  done < "$readme"

  if [[ -n "$heading" ]]; then
    printf '%s' "$heading"
  else
    printf '(no description)'
  fi
}

# Return a single-character status marker for <pkg> in <dots_dir>:
#   ✓  all package files are symlinked into $HOME
#   !  at least one target path is a real file (conflict)
#   ·  not fully linked (package has no files, or some are missing)
repo::package_status() {
  local dots_dir="$1" pkg="$2"
  local pkg_dir
  pkg_dir="$(readlink -f "${dots_dir}/${pkg}")"
  local linked=0 not_linked=0 conflict=0
  local file rel target real

  while IFS= read -r -d '' file; do
    rel="${file#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    if [[ -e "$target" ]]; then
      real="$(readlink -f "$target")"
      if [[ "$real" == "${pkg_dir}/"* ]]; then
        linked=$((linked + 1))
      else
        conflict=$((conflict + 1))
      fi
    else
      not_linked=$((not_linked + 1))
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type f -print0 2>/dev/null)

  if ((conflict > 0)); then
    printf '!'
  elif ((linked > 0 && not_linked == 0)); then
    printf '✓'
  else
    printf '·'
  fi
}
