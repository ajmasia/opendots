# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_create_readme_template() {
  local pkg="$1" desc="$2"
  local desc_line="${desc:-TODO: add a description}"
  printf '# %s\n\n%s\n\n## Files\n\n<!-- List the dotfiles managed by this package -->\n' \
    "$pkg" "$desc_line"
}

cmd_create::run() {
  if [[ $# -eq 0 ]]; then
    cmd_help::run_subcmd "create"
    return 0
  fi

  local pkg="$1"
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local pkg_dir="${dots_dir}/${pkg}"
  if [[ -d "$pkg_dir" ]]; then
    # shellcheck disable=SC2059
    ui::error "$(printf "${MSG_CREATE_EXISTS:-Package already exists: %s}" "$pkg")"
    exit 1
  fi

  local desc=""
  if [[ "${DFY_YES:-0}" != "1" ]]; then
    ui::ask "${MSG_CREATE_ASK_DESC:-Description (optional, Enter to skip): }"
    IFS= read -r desc
  fi

  mkdir -p "$pkg_dir"
  _create_readme_template "$pkg" "$desc" >"${pkg_dir}/README.md"

  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_CREATE_DONE:-Package scaffolded: %s}" "$pkg")"
  # shellcheck disable=SC2059
  ui::info "$(printf "${MSG_CREATE_HINT:-Add your config files under %s}" "$pkg_dir")"
}
