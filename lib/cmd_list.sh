# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_list::run() {
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local -a pkgs
  mapfile -t pkgs < <(repo::list_packages "$dots_dir")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_LIST_EMPTY:-No packages found in %s}" "$dots_dir")"
    return 0
  fi

  local pkg marker
  for pkg in "${pkgs[@]}"; do
    marker="$(repo::package_status "$dots_dir" "$pkg")"
    case "$marker" in
      ✓) ui::ok "$pkg" ;;
      !) ui::warn "$pkg" ;;
      *) ui::info "$pkg" ;;
    esac
  done
}
