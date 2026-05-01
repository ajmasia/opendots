# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_info::run() {
  if [[ $# -eq 0 ]]; then
    cmd_help::run_subcmd "info"
    return 0
  fi

  local pkg="$1"
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local pkg_dir="${dots_dir}/${pkg}"
  if [[ ! -d "$pkg_dir" ]]; then
    # shellcheck disable=SC2059
    ui::error "$(printf "${MSG_PKG_NOT_FOUND:-Package not found: %s}" "$pkg")"
    exit 1
  fi

  local readme="${pkg_dir}/README.md"
  if [[ ! -f "$readme" ]]; then
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_INFO_NO_README:-No README found for %s}" "$pkg")"
    return 0
  fi

  cat "$readme"
}
