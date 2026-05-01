# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_uninstall::run() {
  local clone_dir
  clone_dir="$(cd "$(dirname "$DFY_LIB")" && pwd)"

  local bin_link="$HOME/.local/bin/dfy"
  local bash_comp="$HOME/.local/share/bash-completion/completions/dfy"
  local zsh_comp="$HOME/.local/share/zsh/site-functions/_dfy"
  local config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/dotlify"
  local answer

  [[ -L "$bin_link" ]] && rm "$bin_link" && ui::ok "$(printf 'Removed: %s%s%s' "$(theme::accent)" "$bin_link" "$(theme::reset)")"
  [[ -f "$bash_comp" ]] && rm "$bash_comp" && ui::ok "$(printf 'Removed: %s%s%s' "$(theme::accent)" "$bash_comp" "$(theme::reset)")"
  [[ -f "$zsh_comp" ]] && rm "$zsh_comp" && ui::ok "$(printf 'Removed: %s%s%s' "$(theme::accent)" "$zsh_comp" "$(theme::reset)")"

  if [[ -d "$config_dir" ]]; then
    answer="y"
    if [[ "${DFY_YES:-0}" != "1" ]]; then
      # shellcheck disable=SC2059
      printf '%s' "$(printf "${MSG_UNINSTALL_CONFIG:-Remove config directory %s? [y/N] }" \
        "$(printf '%s%s%s' "$(theme::accent)" "$config_dir" "$(theme::reset)")")"
      read -r answer
    fi
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
      rm -rf "$config_dir"
      ui::ok "$(printf 'Removed: %s%s%s' "$(theme::accent)" "$config_dir" "$(theme::reset)")"
    else
      # shellcheck disable=SC2059
      ui::info "$(printf "${MSG_UNINSTALL_CONFIG_KEPT:-Kept: %s}" \
        "$(printf '%s%s%s' "$(theme::muted)" "$config_dir" "$(theme::reset)")")"
    fi
  fi

  if [[ -d "$clone_dir" ]]; then
    answer="y"
    if [[ "${DFY_YES:-0}" != "1" ]]; then
      # shellcheck disable=SC2059
      printf '%s' "$(printf "${MSG_UNINSTALL_CLONE:-Remove clone directory %s? [y/N] }" \
        "$(printf '%s%s%s' "$(theme::accent)" "$clone_dir" "$(theme::reset)")")"
      read -r answer
    fi
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
      rm -rf "$clone_dir"
      ui::ok "$(printf 'Removed: %s%s%s' "$(theme::accent)" "$clone_dir" "$(theme::reset)")"
    fi
  fi

  printf '\n'
  ui::ok "${MSG_UNINSTALL_OK:-Dotlify uninstalled.}"
}
