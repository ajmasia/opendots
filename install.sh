#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

# Override path for testing
_OS_RELEASE="${_OS_RELEASE:-/etc/os-release}"

# --------------------------------------------------------------------------- #
# Detection                                                                    #
# --------------------------------------------------------------------------- #

install::pkg_manager() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    command -v brew &>/dev/null && printf 'brew' || printf 'unknown'
    return
  fi
  if [[ ! -f "$_OS_RELEASE" ]]; then
    printf 'unknown'
    return
  fi
  local id id_like
  id="$(grep -m1 '^ID=' "$_OS_RELEASE" | cut -d= -f2 | tr -d '"')"
  id_like="$(grep -m1 '^ID_LIKE=' "$_OS_RELEASE" 2>/dev/null | cut -d= -f2 | tr -d '"' || true)"
  case "$id" in
    debian | ubuntu) printf 'apt' ;;
    arch) printf 'pacman' ;;
    fedora | rhel) printf 'dnf' ;;
    *)
      case "$id_like" in
        *debian* | *ubuntu*) printf 'apt' ;;
        *arch*) printf 'pacman' ;;
        *fedora* | *rhel*) printf 'dnf' ;;
        *) printf 'unknown' ;;
      esac
      ;;
  esac
}

install::compose_cmd() {
  case "$1" in
    apt) printf 'sudo apt install -y stow figlet' ;;
    pacman) printf 'sudo pacman -S --noconfirm stow figlet' ;;
    dnf) printf 'sudo dnf install -y stow figlet' ;;
    brew) printf 'brew install stow figlet' ;;
    *) printf '' ;;
  esac
}

# --------------------------------------------------------------------------- #
# Version checks                                                               #
# --------------------------------------------------------------------------- #

install::check_bash() {
  local bash_major="${_INSTALL_BASH_MAJOR:-${BASH_VERSINFO[0]}}"
  if ((bash_major < 4)); then
    printf 'Error: dots requires bash >= 4 (found: %s).\n' "$BASH_VERSION" >&2
    printf 'On macOS: brew install bash\n' >&2
    exit 4
  fi
}

# Returns 0 if v1 >= v2 (MAJOR.MINOR.PATCH), 1 otherwise.
install::version_ge() {
  local v1="$1" v2="$2"
  local maj1 min1 pat1 maj2 min2 pat2
  IFS='.' read -r maj1 min1 pat1 <<<"$v1"
  IFS='.' read -r maj2 min2 pat2 <<<"$v2"
  maj1="${maj1:-0}"
  min1="${min1:-0}"
  pat1="${pat1:-0}"
  maj2="${maj2:-0}"
  min2="${min2:-0}"
  pat2="${pat2:-0}"
  if ((maj1 > maj2)); then return 0; fi
  if ((maj1 < maj2)); then return 1; fi
  if ((min1 > min2)); then return 0; fi
  if ((min1 < min2)); then return 1; fi
  ((pat1 >= pat2))
}

install::check_stow() {
  local version
  version="$(stow --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
  if [[ -z "$version" ]]; then
    printf 'Warning: could not determine stow version.\n' >&2
    return
  fi
  if ! install::version_ge "$version" "2.3.1"; then
    printf 'Error: dots requires stow >= 2.3.1 (found: %s).\n' "$version" >&2
    exit 4
  fi
}

# Populate nameref array with names of missing runtime dependencies.
install::missing_deps() {
  local -n _ref="$1"
  command -v stow &>/dev/null || _ref+=(stow)
  command -v figlet &>/dev/null || _ref+=(figlet)
}

# --------------------------------------------------------------------------- #
# Dependency installation                                                      #
# --------------------------------------------------------------------------- #

install::deps() {
  local yes="${1:-0}"
  local pkg_mgr
  pkg_mgr="$(install::pkg_manager)"

  local -a missing=()
  install::missing_deps missing

  if ((${#missing[@]} == 0)); then
    return 0
  fi

  if [[ "$pkg_mgr" == "unknown" ]]; then
    printf 'Error: unrecognized system. Missing: %s\n' "${missing[*]}" >&2
    printf 'Install manually: stow >= 2.3.1 and figlet, then re-run.\n' >&2
    exit 1
  fi

  local cmd
  cmd="$(install::compose_cmd "$pkg_mgr")"
  printf 'Missing: %s\n' "${missing[*]}"
  printf 'Will run: %s\n' "$cmd"

  if [[ "$yes" != "1" ]]; then
    printf 'Proceed? [y/N] '
    local answer
    read -r answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      printf 'Aborted. Install stow and figlet manually, then re-run.\n' >&2
      exit 1
    fi
  fi

  case "$pkg_mgr" in
    apt) sudo apt install -y stow figlet ;;
    pacman) sudo pacman -S --noconfirm stow figlet ;;
    dnf) sudo dnf install -y stow figlet ;;
    brew) brew install stow figlet ;;
  esac
}

# --------------------------------------------------------------------------- #
# Installation steps                                                           #
# --------------------------------------------------------------------------- #

install::link_binary() {
  local clone_dir="$1"
  local bin_dir="$HOME/.local/bin"
  mkdir -p "$bin_dir"
  local target="${clone_dir}/bin/dots"
  local link="${bin_dir}/dots"
  [[ -L "$link" ]] && rm "$link"
  ln -s "$target" "$link"
  printf 'Linked %s -> %s\n' "$link" "$target"
}

install::completions() {
  local clone_dir="$1"

  local bash_dir="$HOME/.local/share/bash-completion/completions"
  mkdir -p "$bash_dir"
  cp "${clone_dir}/completions/dots.bash" "${bash_dir}/dots"
  printf 'Installed bash completion: %s\n' "${bash_dir}/dots"

  local zsh_dir="$HOME/.local/share/zsh/site-functions"
  mkdir -p "$zsh_dir"
  cp "${clone_dir}/completions/_dots" "${zsh_dir}/_dots"
  printf 'Installed zsh completion: %s\n' "${zsh_dir}/_dots"
}

install::post_install() {
  local bin_dir="$HOME/.local/bin"
  printf '\ndots installed successfully!\n\n'
  printf 'Next steps:\n'
  printf '  1. Ensure %s is in your PATH:\n' "$bin_dir"
  # shellcheck disable=SC2016
  printf '       export PATH="%s:$PATH"\n\n' "$bin_dir"
  printf '  2. Bash completion — add to ~/.bashrc:\n'
  printf '       source ~/.local/share/bash-completion/completions/dots\n\n'
  printf '  3. Zsh completion — add to ~/.zshrc before compinit:\n'
  # shellcheck disable=SC2016
  printf '       fpath=(~/.local/share/zsh/site-functions $fpath)\n\n'
  printf 'The clone must remain at its current path. Updates: git pull.\n'
}

# --------------------------------------------------------------------------- #
# Entry point                                                                  #
# --------------------------------------------------------------------------- #

install::main() {
  local yes=0
  local arg
  for arg in "$@"; do
    case "$arg" in
      --yes | -y) yes=1 ;;
      *) ;;
    esac
  done

  local clone_dir
  clone_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

  install::check_bash
  install::deps "$yes"
  install::check_stow
  install::link_binary "$clone_dir"
  install::completions "$clone_dir"
  install::post_install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install::main "$@"
fi
