# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_create_readme_template() {
  local pkg="$1" desc="$2"
  local desc_line="${desc:-TODO: add a description}"
  printf '# %s config\n\n%s\n\n## Dependencies\n\n<!-- Tools or packages that must be installed -->\n\n## Setup\n\n<!-- Manual steps required after applying this package -->\n\n## Notes\n\n<!-- Observations, links, or anything worth knowing -->\n' \
    "$pkg" "$desc_line"
}

_create_read_desc() {
  local _var="$1"
  if [[ "${DFY_YES:-0}" != "1" ]]; then
    ui::ask "${MSG_CREATE_ASK_DESC:-Description (optional, Enter to skip): }"
    IFS= read -r "${_var?}"
  fi
}

cmd_create::run() {
  local pkg="" subdir=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --subdir | -s)
        shift
        if [[ $# -eq 0 ]]; then
          ui::error "${MSG_CREATE_SUBDIR_MISSING:---subdir / -s requires a path argument}"
          exit 2
        fi
        subdir="$1"
        shift
        ;;
      -*)
        # shellcheck disable=SC2059
        ui::error "$(printf "${MSG_UNKNOWN_FLAG:-Unknown flag: %s}" "$1")"
        exit 2
        ;;
      *)
        pkg="$1"
        shift
        ;;
    esac
  done

  if [[ -z "$pkg" ]]; then
    cmd_help::run_subcmd "create"
    return 0
  fi

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
    local desc=""
    _create_read_desc desc
    _create_readme_template "$pkg" "$desc" >"$readme"
    [[ -f "${pkg_dir}/.stow-local-ignore" ]] \
      || printf '%s\n' '^README\.md$' >"${pkg_dir}/.stow-local-ignore"
    [[ -n "$subdir" ]] && mkdir -p "${pkg_dir}/${subdir}"
    repo::update_readme_table "$dots_dir" "$pkg" "$desc"
    # shellcheck disable=SC2059
    ui::ok "$(printf "${MSG_CREATE_README_DONE:-README created for %s}" "$pkg")"
    return 0
  fi

  local desc=""
  _create_read_desc desc
  mkdir -p "$pkg_dir"
  _create_readme_template "$pkg" "$desc" >"$readme"
  printf '%s\n' '^README\.md$' >"${pkg_dir}/.stow-local-ignore"
  [[ -n "$subdir" ]] && mkdir -p "${pkg_dir}/${subdir}"
  repo::update_readme_table "$dots_dir" "$pkg" "$desc"
  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_CREATE_DONE:-Package scaffolded: %s}" "$pkg")"
  printf '\n'
  ui::step "${MSG_CREATE_NEXT_STEPS:-Next steps:}"
  # shellcheck disable=SC2059
  printf '  %s\n' "$(printf "${MSG_CREATE_NEXT_ADD:-Add dotfiles to %s then run: dfy link %s}" \
    "$(printf '%s%s%s' "$(theme::accent)" "$pkg_dir" "$(theme::reset)")" \
    "$(printf '%s%s%s' "$(theme::info)" "$pkg" "$(theme::reset)")")"
  # shellcheck disable=SC2059
  printf '  %s\n' "$(printf "${MSG_CREATE_NEXT_ADOPT:-Or adopt existing files: dfy adopt %s}" \
    "$(printf '%s%s%s' "$(theme::info)" "$pkg" "$(theme::reset)")")"
}
