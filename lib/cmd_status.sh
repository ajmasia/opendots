# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_status::run() {
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  # shellcheck disable=SC2059
  ui::info "$(printf "${MSG_STATUS_DOTFILES:-Dotfiles: %s}" \
    "$(printf '%s%s%s' "$(theme::accent)" "$dots_dir" "$(theme::reset)")")"

  if [[ -n "${DFY_PROFILE:-}" ]]; then
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_STATUS_PROFILE:-Active profile: %s}" \
      "$(printf '%s%s%s' "$(theme::accent)" "${DFY_PROFILE}" "$(theme::reset)")")"
  else
    ui::info "${MSG_STATUS_NO_PROFILE:-(no active profile)}"
  fi

  local -a pkgs
  mapfile -t pkgs < <(repo::list_packages "$dots_dir")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    printf '\n'
    ui::info "${MSG_STATUS_NONE}"
    return 0
  fi

  local -a linked=() conflicts=() not_linked=()
  local pkg marker
  for pkg in "${pkgs[@]}"; do
    marker="$(repo::package_status "$dots_dir" "$pkg")"
    case "$marker" in
      ✓) linked+=("$pkg") ;;
      !) conflicts+=("$pkg") ;;
      *) not_linked+=("$pkg") ;;
    esac
  done

  if [[ ${#linked[@]} -gt 0 ]]; then
    printf '\n'
    # shellcheck disable=SC2059
    ui::step "$(printf "${MSG_STATUS_LINKED:-Linked packages (%s):}" "${#linked[@]}")"
    for pkg in "${linked[@]}"; do
      ui::ok "$pkg"
    done
  fi

  if [[ ${#conflicts[@]} -gt 0 ]]; then
    printf '\n'
    # shellcheck disable=SC2059
    ui::step "$(printf "${MSG_STATUS_CONFLICTS:-Conflicts (%s):}" "${#conflicts[@]}")"
    for pkg in "${conflicts[@]}"; do
      ui::warn "$(printf '%s%s%s — %s' \
        "$(theme::warning)" "$pkg" "$(theme::reset)" \
        "${MSG_STATUS_CONFLICT_HINT:-target exists, run: dfy adopt}")"
    done
  fi

  if [[ ${#not_linked[@]} -gt 0 ]]; then
    printf '\n'
    # shellcheck disable=SC2059
    ui::step "$(printf "${MSG_STATUS_NOT_LINKED:-Not linked (%s):}" "${#not_linked[@]}")"
    for pkg in "${not_linked[@]}"; do
      ui::off "$pkg"
    done
  fi
}
