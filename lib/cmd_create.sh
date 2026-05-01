# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_create_readme_template() {
  local pkg="$1" desc="$2"
  local desc_line="${desc:-TODO: add a description}"
  printf '# %s\n\n%s\n\n## Files\n\n<!-- List the dotfiles managed by this package -->\n' \
    "$pkg" "$desc_line"
}

_create_ask_desc() {
  local desc=""
  if [[ "${DFY_YES:-0}" != "1" ]]; then
    ui::ask "${MSG_CREATE_ASK_DESC:-Description (optional, Enter to skip): }"
    IFS= read -r desc
  fi
  printf '%s' "$desc"
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
  local readme="${pkg_dir}/README.md"

  if [[ -d "$pkg_dir" ]]; then
    if [[ -f "$readme" ]]; then
      # shellcheck disable=SC2059
      ui::error "$(printf "${MSG_CREATE_EXISTS:-Package already exists and has a README: %s}" "$pkg")"
      exit 1
    fi
    # Package exists but has no README — create just the README.
    local desc
    desc="$(_create_ask_desc)"
    _create_readme_template "$pkg" "$desc" >"$readme"
    # shellcheck disable=SC2059
    ui::ok "$(printf "${MSG_CREATE_README_DONE:-README created for %s}" "$pkg")"
    return 0
  fi

  local desc
  desc="$(_create_ask_desc)"
  mkdir -p "$pkg_dir"
  _create_readme_template "$pkg" "$desc" >"$readme"
  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_CREATE_DONE:-Package scaffolded: %s}" "$pkg")"
  # shellcheck disable=SC2059
  ui::info "$(printf "${MSG_CREATE_HINT:-Add your config files under %s}" "$pkg_dir")"
}
