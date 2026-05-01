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

  [[ -L "$bin_link" ]] && rm "$bin_link" && printf 'Removed: %s\n' "$bin_link"
  [[ -f "$bash_comp" ]] && rm "$bash_comp" && printf 'Removed: %s\n' "$bash_comp"
  [[ -f "$zsh_comp" ]] && rm "$zsh_comp" && printf 'Removed: %s\n' "$zsh_comp"

  if [[ -d "$config_dir" ]]; then
    answer="y"
    if [[ "${DFY_YES:-0}" != "1" ]]; then
      # shellcheck disable=SC2059
      printf "${MSG_UNINSTALL_CONFIG:-Remove config directory %s? [y/N] }" "$config_dir"
      read -r answer
    fi
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
      rm -rf "$config_dir"
      printf 'Removed: %s\n' "$config_dir"
    else
      # shellcheck disable=SC2059
      printf "${MSG_UNINSTALL_CONFIG_KEPT:-Kept: %s}\n" "$config_dir"
    fi
  fi

  if [[ -d "$clone_dir" ]]; then
    answer="y"
    if [[ "${DFY_YES:-0}" != "1" ]]; then
      # shellcheck disable=SC2059
      printf "${MSG_UNINSTALL_CLONE:-Remove clone directory %s? [y/N] }" "$clone_dir"
      read -r answer
    fi
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
      rm -rf "$clone_dir"
      printf 'Removed: %s\n' "$clone_dir"
    fi
  fi

  printf '\n%s\n' "${MSG_UNINSTALL_OK:-Dotlify uninstalled.}"
}
