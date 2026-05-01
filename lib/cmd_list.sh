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

  local -a descs
  local max_len=0 pkg desc
  for pkg in "${pkgs[@]}"; do
    desc="$(repo::pkg_description "$dots_dir" "$pkg")"
    descs+=("$desc")
    if [[ -n "$desc" && ${#pkg} -gt $max_len ]]; then
      max_len=${#pkg}
    fi
  done

  local i pad
  for ((i = 0; i < ${#pkgs[@]}; i++)); do
    pkg="${pkgs[$i]}"
    desc="${descs[$i]}"
    if [[ -n "$desc" ]]; then
      pad=$(( max_len - ${#pkg} ))
      printf '  %s-%s %s%s%s%*s  %s%s%s\n' \
        "$(theme::muted)" "$(theme::reset)" \
        "$(theme::info)" "$pkg" "$(theme::reset)" \
        "$pad" "" \
        "$(theme::subtext)" "$desc" "$(theme::reset)"
    else
      printf '  %s-%s %s%s%s\n' \
        "$(theme::muted)" "$(theme::reset)" \
        "$(theme::info)" "$pkg" "$(theme::reset)"
    fi
  done
}
