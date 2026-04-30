# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_install::run() {
  local -a pkgs=("$@")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    if [[ -n "${DOTS_PROFILE:-}" ]]; then
      local _profile_pkgs
      _profile_pkgs="$(profile::load "${DOTS_PROFILE}")"
      mapfile -t pkgs <<<"$_profile_pkgs"
    else
      printf '%s\n' "${MSG_HELP_INSTALL}" >&2
      printf '%s\n' "${MSG_USAGE_HINT}" >&2
      exit 2
    fi
  fi

  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local pkg
  for pkg in "${pkgs[@]}"; do
    local pkg_dir="${dots_dir}/${pkg}"
    if [[ ! -d "$pkg_dir" ]]; then
      # shellcheck disable=SC2059
      printf "${MSG_PKG_NOT_FOUND:-Package not found: %s}\n" "$pkg" >&2
      exit 1
    fi

    local -a conflicts=()
    _install_check_conflicts "$pkg_dir" conflicts

    if [[ ${#conflicts[@]} -gt 0 ]]; then
      printf '%s\n' "${MSG_INSTALL_CONFLICT}" >&2
      local f
      for f in "${conflicts[@]}"; do
        printf '  %s\n' "$f" >&2
      done
      printf '%s\n' "${MSG_INSTALL_ADOPT_HINT}" >&2
      exit 3
    fi

    _install_stow "$pkg" "$dots_dir"
    # shellcheck disable=SC2059
    ui::ok "$(printf "${MSG_INSTALL_OK:-Installed: %s}" "$pkg")"
  done
}

_install_check_conflicts() {
  local pkg_dir="$1"
  local -n _conflicts="$2"
  local file rel target
  while IFS= read -r -d '' file; do
    rel="${file#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    if [[ -e "$target" && ! -L "$target" ]]; then
      _conflicts+=("$target")
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type f -print0 2>/dev/null)
}

_install_stow() {
  local pkg="$1" dots_dir="$2"
  local -a stow_args=(-d "$dots_dir" -t "$HOME")
  if [[ "${DOTS_DRY_RUN:-0}" == "1" ]]; then
    stow_args+=(-n -v)
    # In dry-run, stow writes planned operations to stderr — show them as info.
    stow "${stow_args[@]}" "$pkg" 2> >(while IFS= read -r line; do ui::info "$line"; done)
  else
    stow "${stow_args[@]}" "$pkg" 2> >(while IFS= read -r line; do ui::error "$line"; done >&2)
  fi
}
