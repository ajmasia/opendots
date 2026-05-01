#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Bash tab completion for the dfy command. Source this file in ~/.bashrc or
# drop it in /etc/bash_completion.d/.

_dfy_resolve_dir() {
  local dir="${DFY_DIR:-}"
  if [[ -z "$dir" ]]; then
    local config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/dotlify/config"
    if [[ -f "$config_file" ]]; then
      local line
      line="$(grep -m1 '^dir=' "$config_file" 2>/dev/null || true)"
      if [[ -n "$line" ]]; then
        dir="${line#dir=}"
        dir="${dir/#\~/$HOME}"
        [[ -d "$dir" ]] || dir=""
      fi
    fi
  fi
  printf '%s' "${dir:-${HOME}/.dotfiles}"
}

_dfy_packages() {
  local dir="$1"
  [[ -d "$dir" ]] || return
  local entry name
  while IFS= read -r -d '' entry; do
    name="${entry##*/}"
    [[ "$name" == profiles || "$name" == .* ]] && continue
    printf '%s\n' "$name"
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
}

_dfy_profiles() {
  local dir="$1/profiles"
  [[ -d "$dir" ]] || return
  local f
  for f in "$dir"/*.txt; do
    [[ -f "$f" ]] && printf '%s\n' "${f##*/}" | sed 's/\.txt$//'
  done
}

_dfy_complete() {
  local cur prev subcmd
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  subcmd=""

  local -a subcommands=(install remove adopt list status doctor update uninstall help)
  local -a global_flags=(--help -h --version -V --no-color --dry-run --profile --yes -y --dir --lang)

  local i
  for ((i = 1; i < COMP_CWORD; i++)); do
    case "${COMP_WORDS[i]}" in
      install | remove | adopt | list | status | doctor | update | uninstall | help)
        subcmd="${COMP_WORDS[i]}"
        break
        ;;
    esac
  done

  if [[ "$prev" == "--profile" ]]; then
    local dots_dir
    dots_dir="$(_dfy_resolve_dir)"
    local -a profiles
    mapfile -t profiles < <(_dfy_profiles "$dots_dir")
    mapfile -t COMPREPLY < <(compgen -W "${profiles[*]}" -- "$cur")
    return
  fi

  if [[ "$prev" == "--dir" ]]; then
    mapfile -t COMPREPLY < <(compgen -d -- "$cur")
    return
  fi

  if [[ "$prev" == "--lang" ]]; then
    mapfile -t COMPREPLY < <(compgen -W "en es" -- "$cur")
    return
  fi

  if [[ -z "$subcmd" ]]; then
    if [[ "$cur" == -* ]]; then
      mapfile -t COMPREPLY < <(compgen -W "${global_flags[*]}" -- "$cur")
    else
      mapfile -t COMPREPLY < <(compgen -W "${subcommands[*]}" -- "$cur")
    fi
    return
  fi

  if [[ "$cur" == -* ]]; then
    mapfile -t COMPREPLY < <(compgen -W "${global_flags[*]}" -- "$cur")
    return
  fi

  case "$subcmd" in
    install | remove | adopt)
      local dots_dir
      dots_dir="$(_dfy_resolve_dir)"
      local -a packages
      mapfile -t packages < <(_dfy_packages "$dots_dir")
      mapfile -t COMPREPLY < <(compgen -W "${packages[*]}" -- "$cur")
      ;;
  esac
}

complete -F _dfy_complete dfy
