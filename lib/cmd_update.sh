# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_update::run() {
  local clone_dir
  clone_dir="$(cd "$(dirname "$DOTS_LIB")" && pwd)"

  if [[ ! -d "${clone_dir}/.git" ]]; then
    # shellcheck disable=SC2059
    printf "${MSG_UPDATE_NOT_GIT:-Not a git repository, cannot update: %s}\n" "$clone_dir" >&2
    exit 1
  fi

  printf '%s\n' "${MSG_UPDATE_PULLING:-Pulling latest changes...}"
  git -C "$clone_dir" pull --ff-only

  local bash_comp="$HOME/.local/share/bash-completion/completions/opendots"
  local zsh_comp="$HOME/.local/share/zsh/site-functions/_opendots"

  if [[ -f "$bash_comp" ]]; then
    printf '%s\n' "${MSG_UPDATE_COMP:-Updating shell completions...}"
    cp "${clone_dir}/completions/opendots.bash" "$bash_comp"
  fi
  if [[ -f "$zsh_comp" ]]; then
    [[ -f "$bash_comp" ]] || printf '%s\n' "${MSG_UPDATE_COMP:-Updating shell completions...}"
    cp "${clone_dir}/completions/_opendots" "$zsh_comp"
  fi

  printf '%s\n' "${MSG_UPDATE_OK:-OpenDots updated successfully.}"
}
