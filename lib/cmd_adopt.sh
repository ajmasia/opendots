# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_adopt::run() {
  local -a pkgs=("$@")

  if [[ ${#pkgs[@]} -ne 1 ]]; then
    ui::error "${MSG_HELP_ADOPT}"
    ui::info "${MSG_USAGE_HINT}"
    exit 2
  fi

  local pkg="${pkgs[0]}"
  local dots_dir
  dots_dir="$(repo::resolve_dir)"
  local pkg_dir="${dots_dir}/${pkg}"

  if [[ ! -d "$pkg_dir" ]]; then
    # shellcheck disable=SC2059
    ui::error "$(printf "${MSG_PKG_NOT_FOUND:-Package not found: %s}" "$pkg")"
    exit 1
  fi

  # Collect real (non-symlink) files to adopt, using two complementary scans:
  #
  # Scan A — package files: for each file already in the package, check if a
  # real counterpart exists at the corresponding HOME path.
  #
  # Scan B — package directories: for each directory in the package tree,
  # collect all real files that live recursively inside the matching HOME
  # directory.  This handles the common case where the user creates a package
  # with an empty directory scaffold (e.g. `dfy create hyprland -s .config/hypr`)
  # before any files have been placed in the package.
  #
  # An associative array deduplicates results from both scans.

  local -a to_adopt=()
  local -A _seen=()
  local file rel target

  _adopt_add() {
    local f="$1"
    if [[ -z "${_seen["$f"]+x}" ]]; then
      _seen["$f"]=1
      to_adopt+=("$f")
    fi
  }

  # Scan A: package files with real HOME counterparts
  while IFS= read -r -d '' file; do
    rel="${file#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    if [[ -e "$target" && ! -L "$target" ]] && ! _link_stow_owns_parent "$target" "$pkg_dir"; then
      _adopt_add "$target"
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type f -print0 2>/dev/null)

  # Scan B: real files under HOME dirs that mirror package directories.
  #
  # For each directory in the package tree we locate the matching HOME dir.
  # - Leaf directories (no child dirs in the package): scan the HOME dir
  #   recursively so HOME subdirectories not yet in the package are also
  #   captured.
  # - Non-leaf directories (have child dirs in the package): scan only direct
  #   files (children handle their own subtrees, preventing an intermediate dir
  #   like .config/ from pulling in the entire $HOME/.config/).

  # Scan B: for each LEAF directory in the package (one with no child dirs),
  # collect all real files found recursively under the matching HOME dir.
  # Non-leaf directories (e.g. .config/ when .config/hypr/ also exists) are
  # skipped entirely — their direct files are already covered by Scan A and
  # scanning them would pull in unrelated HOME files (mimeapps.list, etc.).

  local -a _pkg_dirs=()
  local dir
  while IFS= read -r -d '' dir; do
    _pkg_dirs+=("$dir")
  done < <(find "$pkg_dir" -mindepth 1 -type d -print0 2>/dev/null)

  local home_dir _d
  for dir in "${_pkg_dirs[@]+"${_pkg_dirs[@]}"}"; do
    # Skip if another package dir is nested inside this one (non-leaf)
    local _leaf=1
    for _d in "${_pkg_dirs[@]+"${_pkg_dirs[@]}"}"; do
      [[ "$_d" != "$dir" && "$_d" == "$dir"/* ]] && _leaf=0 && break
    done
    [[ "$_leaf" == "0" ]] && continue

    rel="${dir#"${pkg_dir}"/}"
    home_dir="${HOME}/${rel}"
    [[ -d "$home_dir" && ! -L "$home_dir" ]] || continue

    while IFS= read -r -d '' file; do
      [[ -L "$file" ]] && continue
      _adopt_add "$file"
    done < <(find "$home_dir" -mindepth 1 -type f -print0 2>/dev/null)
  done

  unset -f _adopt_add

  if [[ ${#to_adopt[@]} -eq 0 ]]; then
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_ADOPT_NOTHING:-Nothing to adopt for package: %s}" "$pkg")"
    return 0
  fi

  ui::info "${MSG_ADOPT_PREVIEW}"
  local f
  for f in "${to_adopt[@]}"; do
    printf '  %s%s%s\n' "$(theme::accent)" "$f" "$(theme::reset)"
  done
  printf '\n'

  if [[ "${DFY_YES:-0}" != "1" ]]; then
    ui::ask "${MSG_ADOPT_CONFIRM}"
    local answer
    read -r answer
    printf '\n'
    if [[ "$answer" != [YySs]* ]]; then
      ui::info "${MSG_ADOPT_ABORTED}"
      exit 1
    fi
  fi

  # Move each HOME file into the package, preserving subdirectory structure.
  for f in "${to_adopt[@]}"; do
    local rel_from_home="${f#"${HOME}"/}"
    local pkg_dest="${pkg_dir}/${rel_from_home}"
    mkdir -p "$(dirname "$pkg_dest")"
    mv "$f" "$pkg_dest"
  done

  # Remove HOME directories that are now empty so stow can replace them
  # with a directory-level symlink instead of tree-folding.  We work from
  # deepest to shallowest (sort -rz) and use rmdir, which is a no-op when
  # the directory is not empty (e.g. it still holds unrelated files).
  local _d _rel_d _home_d
  for _d in "${_pkg_dirs[@]+"${_pkg_dirs[@]}"}"; do
    local _is_leaf=1
    local _other
    for _other in "${_pkg_dirs[@]+"${_pkg_dirs[@]}"}"; do
      [[ "$_other" != "$_d" && "$_other" == "$_d"/* ]] && _is_leaf=0 && break
    done
    [[ "$_is_leaf" == "0" ]] && continue
    _rel_d="${_d#"${pkg_dir}"/}"
    _home_d="${HOME}/${_rel_d}"
    [[ -d "$_home_d" && ! -L "$_home_d" ]] || continue
    while IFS= read -r -d '' _empty; do
      rmdir "$_empty" 2>/dev/null || true
    done < <(find "$_home_d" -mindepth 0 -type d -print0 2>/dev/null | sort -rz)
  done

  stow -d "$dots_dir" -t "$HOME" "$pkg" \
    2> >(while IFS= read -r line; do ui::error "$line"; done >&2)
  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_ADOPT_OK:-Adopted: %s}" "$pkg")"
}
