#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

DOTLIFY_REPO="https://github.com/ajmasia/dotlify"
DOTLIFY_CLONE_DIR="${HOME}/.local/share/dotlify"

# Override path for testing
_OS_RELEASE="${_OS_RELEASE:-/etc/os-release}"

# --------------------------------------------------------------------------- #
# Inline color helpers (Catppuccin Mocha — no external deps)                  #
# --------------------------------------------------------------------------- #

_install_colors() {
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    _C_ACCENT=$'\033[38;2;203;166;247m'
    _C_INFO=$'\033[38;2;137;220;235m'
    _C_OK=$'\033[38;2;166;227;161m'
    _C_WARN=$'\033[38;2;249;226;175m'
    _C_ERROR=$'\033[38;2;243;139;168m'
    _C_TEXT=$'\033[38;2;205;214;244m'
    _C_MUTED=$'\033[38;2;108;112;134m'
    _C_RESET=$'\033[0m'
  else
    _C_ACCENT='' _C_INFO='' _C_OK='' _C_WARN='' _C_ERROR=''
    _C_TEXT='' _C_MUTED='' _C_RESET=''
  fi
}

_install_colors

_ui_step() { printf "${_C_ACCENT}[>]${_C_RESET} ${_C_TEXT}%s${_C_RESET}\n" "$*"; }
_ui_ok() { printf "${_C_OK}[+]${_C_RESET} ${_C_TEXT}%s${_C_RESET}\n" "$*"; }
_ui_info() { printf "${_C_INFO}[i]${_C_RESET} ${_C_TEXT}%s${_C_RESET}\n" "$*"; }
_ui_warn() { printf "${_C_WARN}[!]${_C_RESET} ${_C_TEXT}%s${_C_RESET}\n" "$*" >&2; }
_ui_error() { printf "${_C_ERROR}[x]${_C_RESET} ${_C_TEXT}%s${_C_RESET}\n" "$*" >&2; }
_ui_ask() { printf "${_C_WARN}[?]${_C_RESET} ${_C_TEXT}%s${_C_RESET} " "$*"; }
_ui_section() { printf "\n${_C_ACCENT}%s${_C_RESET}\n" "$*"; }
_ui_value() { printf '%s%s%s' "${_C_INFO}" "$*" "${_C_RESET}"; }
_ui_muted() { printf '%s%s%s' "${_C_MUTED}" "$*" "${_C_RESET}"; }

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
    _ui_error "dfy requires bash >= 4 (found: $(_ui_value "$BASH_VERSION")). On macOS: brew install bash"
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
    _ui_warn "Could not determine stow version."
    return
  fi
  if ! install::version_ge "$version" "2.3.1"; then
    _ui_error "dfy requires stow >= 2.3.1 (found: $(_ui_value "$version"))"
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
    _ui_error "Unrecognized system. Missing: $(_ui_value "${missing[*]}")"
    _ui_info "Install manually: stow >= 2.3.1 and figlet, then re-run."
    exit 1
  fi

  local cmd
  cmd="$(install::compose_cmd "$pkg_mgr")"
  _ui_warn "Missing: $(_ui_value "${missing[*]}")"
  _ui_info "Will run: $(_ui_value "$cmd")"

  if [[ "$yes" != "1" ]]; then
    _ui_ask "Proceed? [y/N]"
    local answer
    read -r answer
    printf '\n'
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      _ui_error "Aborted. Install stow and figlet manually, then re-run."
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
# Git / remote clone                                                           #
# --------------------------------------------------------------------------- #

install::check_git() {
  if ! command -v git &>/dev/null; then
    _ui_error "git is required to install Dotlify. Install it and re-run."
    exit 4
  fi
}

# Clone or pull the repo; prints clone_dir to stdout, progress to stderr.
install::clone_or_update() {
  local dest="$DOTLIFY_CLONE_DIR"
  if [[ -d "${dest}/.git" ]]; then
    _ui_step "Updating existing clone at $(_ui_value "$dest") ..." >&2
    printf '\n' >&2
    git -C "$dest" pull --ff-only >&2
  else
    _ui_step "Cloning Dotlify to $(_ui_value "$dest") ..." >&2
    printf '\n' >&2
    git clone "$DOTLIFY_REPO" "$dest" >&2
  fi
  printf '\n' >&2
  printf '%s' "$dest"
}

# --------------------------------------------------------------------------- #
# Installation steps                                                           #
# --------------------------------------------------------------------------- #

install::link_binary() {
  local clone_dir="$1"
  local bin_dir="$HOME/.local/bin"
  mkdir -p "$bin_dir"
  local target="${clone_dir}/bin/dfy"
  local link="${bin_dir}/dfy"
  [[ -L "$link" ]] && rm "$link"
  ln -s "$target" "$link"
  _ui_ok "Linked $(_ui_value "$link") -> $(_ui_muted "$target")"
}

install::completions() {
  local clone_dir="$1"

  local bash_dir="$HOME/.local/share/bash-completion/completions"
  mkdir -p "$bash_dir"
  cp "${clone_dir}/completions/dfy.bash" "${bash_dir}/dfy"
  _ui_ok "Bash completion: $(_ui_value "${bash_dir}/dfy")"

  local zsh_dir="$HOME/.local/share/zsh/site-functions"
  mkdir -p "$zsh_dir"
  cp "${clone_dir}/completions/_dfy" "${zsh_dir}/_dfy"
  _ui_ok "Zsh completion:  $(_ui_value "${zsh_dir}/_dfy")"
}

install::post_install() {
  local bin_dir="$HOME/.local/bin"
  _ui_ok "Dotlify installed successfully!"
  _ui_section "Next steps:"
  printf '  %s Ensure %s is in your PATH:\n' "$(_ui_muted "1.")" "$(_ui_value "$bin_dir")"
  printf '       %s\n' "$(_ui_muted "export PATH=\"${bin_dir}:\$PATH\"")"
  printf '\n'
  printf '  %s Bash completion — add to ~/.bashrc:\n' "$(_ui_muted "2.")"
  printf '       %s\n' "$(_ui_muted "source ~/.local/share/bash-completion/completions/dfy")"
  printf '\n'
  printf '  %s Zsh completion — add to ~/.zshrc before compinit:\n' "$(_ui_muted "3.")"
  printf '       %s\n' "$(_ui_muted "fpath=(~/.local/share/zsh/site-functions \$fpath)")"
  printf '\n'
  printf '%s  %s\n' "$(_ui_muted "Update:")" "$(_ui_value "dfy update")"
  printf '%s  %s\n' "$(_ui_muted "Uninstall:")" "$(_ui_value "dfy uninstall")"
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
  if [[ -z "${BASH_SOURCE[0]:-}" ]] || ! [[ -f "${BASH_SOURCE[0]:-}" ]]; then
    install::check_git
    clone_dir="$(install::clone_or_update)"
  else
    clone_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
  fi

  install::check_bash
  install::deps "$yes"
  install::check_stow
  install::link_binary "$clone_dir"
  install::completions "$clone_dir"
  install::post_install
}

if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]; then
  install::main "$@"
fi
