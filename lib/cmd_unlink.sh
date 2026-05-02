# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_unlink_is_linked() {
  local pkg_dir="$1"
  local rel target

  # File-level symlinks (stow tree-folded links to individual files)
  local file
  while IFS= read -r -d '' file; do
    rel="${file#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    [[ -L "$target" ]] && return 0
  done < <(find "$pkg_dir" -mindepth 1 -type f -print0 2>/dev/null)

  # Directory-level symlinks (stow linked the whole dir as one symlink)
  local dir
  while IFS= read -r -d '' dir; do
    rel="${dir#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    [[ -L "$target" ]] && return 0
  done < <(find "$pkg_dir" -mindepth 1 -type d -print0 2>/dev/null)

  return 1
}

# Remove directory-level symlinks in HOME whose target resolves to a dir
# inside pkg_dir.  stow -D handles file-level symlinks but does not clean
# up directory symlinks created when the whole dir was linked as one unit.
_unlink_dir_symlinks() {
  local pkg_dir="$1"
  local dir rel home_target link_target
  while IFS= read -r -d '' dir; do
    rel="${dir#"${pkg_dir}"/}"
    home_target="${HOME}/${rel}"
    [[ -L "$home_target" ]] || continue
    link_target="$(readlink "$home_target")"
    # Resolve relative symlinks
    [[ "$link_target" != /* ]] && link_target="$(dirname "$home_target")/${link_target}"
    [[ "$link_target" == "$pkg_dir"* ]] && rm "$home_target"
  done < <(find "$pkg_dir" -mindepth 1 -type d -print0 2>/dev/null)
}

cmd_unlink::run() {
  local -a pkgs=("$@")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    if [[ -n "${DFY_PROFILE:-}" ]]; then
      local _profile_pkgs
      _profile_pkgs="$(profile::load "${DFY_PROFILE}")"
      mapfile -t pkgs <<<"$_profile_pkgs"
    else
      ui::error "${MSG_HELP_UNLINK}"
      ui::info "${MSG_USAGE_HINT}"
      exit 2
    fi
  fi

  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local _any_unlinked=0
  local pkg
  for pkg in "${pkgs[@]}"; do
    local pkg_dir="${dots_dir}/${pkg}"
    # Silent no-op when nothing from this package is currently linked.
    if ! _unlink_is_linked "$pkg_dir"; then
      continue
    fi
    local -a stow_args=(-d "$dots_dir" -t "$HOME" -D)
    if [[ "${DFY_DRY_RUN:-0}" == "1" ]]; then
      stow_args+=(-n -v)
    fi
    stow_args+=("$pkg")
    local _err
    if ! _err="$(stow "${stow_args[@]}" 2>&1)"; then
      printf '%s\n' "$_err" >&2
    fi
    # stow -D handles file-level symlinks; clean up directory-level ones.
    _unlink_dir_symlinks "$pkg_dir"
    # shellcheck disable=SC2059
    ui::ok "$(printf "${MSG_UNLINK_OK:-Unlinked: %s}" "$pkg")"
    _any_unlinked=1
  done

  # Only show the hint when at least one package was actually unlinked.
  if [[ "$_any_unlinked" == "1" ]]; then
    ui::info "${MSG_UNLINK_REPO_HINT:-Package files remain in your dotfiles repository.}"
  fi
}
