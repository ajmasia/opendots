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

  # Identify real files in $HOME that match package structure.
  local -a to_adopt=()
  local file rel target
  while IFS= read -r -d '' file; do
    rel="${file#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    if [[ -e "$target" && ! -L "$target" ]]; then
      to_adopt+=("$target")
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type f -print0 2>/dev/null)

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
    if [[ "$answer" != [Yy]* ]]; then
      ui::info "${MSG_ADOPT_ABORTED}"
      exit 1
    fi
  fi

  stow -d "$dots_dir" -t "$HOME" --adopt "$pkg" \
    2> >(while IFS= read -r line; do ui::error "$line"; done >&2)
  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_ADOPT_OK:-Adopted: %s}" "$pkg")"
}
