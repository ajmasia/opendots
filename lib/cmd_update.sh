# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_update::run() {
  if os::is_nix_store; then
    ui::info "${MSG_UPDATE_NIX}"
    printf '%s\n' "${MSG_UPDATE_NIX_CMD}"
    return 0
  fi

  local clone_dir
  clone_dir="$(cd "$(dirname "$DFY_LIB")" && pwd)"

  if [[ ! -d "${clone_dir}/.git" ]]; then
    # shellcheck disable=SC2059
    ui::error "$(printf "${MSG_UPDATE_NOT_GIT:-Not a git repository, cannot update: %s}" "$clone_dir")"
    exit 1
  fi

  ui::step "${MSG_UPDATE_PULLING:-Pulling latest changes...}"
  git -C "$clone_dir" pull --ff-only

  local bash_comp="$HOME/.local/share/bash-completion/completions/dfy"
  local zsh_comp="$HOME/.local/share/zsh/site-functions/_dfy"
  local comp_printed=0

  if [[ -f "$bash_comp" ]]; then
    ui::step "${MSG_UPDATE_COMP:-Updating shell completions...}"
    comp_printed=1
    cp "${clone_dir}/completions/dfy.bash" "$bash_comp"
  fi
  if [[ -f "$zsh_comp" ]]; then
    [[ "$comp_printed" == "1" ]] || ui::step "${MSG_UPDATE_COMP:-Updating shell completions...}"
    cp "${clone_dir}/completions/_dfy" "$zsh_comp"
  fi

  ui::ok "${MSG_UPDATE_OK:-Dotlify updated successfully.}"
}
