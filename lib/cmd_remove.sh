# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_remove_is_linked() {
  local pkg_dir="$1"
  local file rel target
  while IFS= read -r -d '' file; do
    rel="${file#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    if [[ -L "$target" ]]; then
      return 0
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type f -print0 2>/dev/null)
  return 1
}

cmd_remove::run() {
  local -a pkgs=("$@")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    if [[ -n "${DOTS_PROFILE:-}" ]]; then
      local _profile_pkgs
      _profile_pkgs="$(profile::load "${DOTS_PROFILE}")"
      mapfile -t pkgs <<<"$_profile_pkgs"
    else
      printf '%s\n' "${MSG_HELP_REMOVE}" >&2
      printf '%s\n' "${MSG_USAGE_HINT}" >&2
      exit 2
    fi
  fi

  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local pkg
  for pkg in "${pkgs[@]}"; do
    local pkg_dir="${dots_dir}/${pkg}"
    # Silent no-op when nothing from this package is currently linked.
    if ! _remove_is_linked "$pkg_dir"; then
      continue
    fi
    local -a stow_args=(-d "$dots_dir" -t "$HOME" -D)
    if [[ "${DOTS_DRY_RUN:-0}" == "1" ]]; then
      stow_args+=(-n -v)
    fi
    stow_args+=("$pkg")
    stow "${stow_args[@]}" 2>/dev/null || true
    # shellcheck disable=SC2059
    ui::ok "$(printf "${MSG_REMOVE_OK:-Removed: %s}" "$pkg")"
  done
}
