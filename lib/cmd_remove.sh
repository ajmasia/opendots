# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_remove::run() {
  local -a pkgs=("$@")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    printf '%s\n' "${MSG_HELP_REMOVE}" >&2
    printf '%s\n' "${MSG_USAGE_HINT}" >&2
    exit 2
  fi

  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local pkg
  for pkg in "${pkgs[@]}"; do
    local -a stow_args=(-d "$dots_dir" -t "$HOME" -D)
    if [[ "${DOTS_DRY_RUN:-0}" == "1" ]]; then
      stow_args+=(-n -v)
    fi
    stow_args+=("$pkg")
    # Idempotent: suppress errors when package is not currently linked.
    stow "${stow_args[@]}" 2>/dev/null || true
    # shellcheck disable=SC2059
    ui::ok "$(printf "${MSG_REMOVE_OK:-Removed: %s}" "$pkg")"
  done
}
