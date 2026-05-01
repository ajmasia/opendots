# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_delete_pkg_is_linked() {
  local pkg_dir="$1"
  local file rel target
  while IFS= read -r -d '' file; do
    rel="${file#"${pkg_dir}"/}"
    target="${HOME}/${rel}"
    if [[ -L "$target" ]]; then
      return 0
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type f -print0 2>/dev/null)
  return 1
}

# Warn if the given path has untracked or uncommitted changes in its git repo.
_delete_git_check() {
  local dots_dir="$1" path="$2"
  git -C "$dots_dir" rev-parse --is-inside-work-tree &>/dev/null || return 0
  local dirty
  dirty="$(git -C "$dots_dir" status --short -- "$path" 2>/dev/null)" || true
  if [[ -n "$dirty" ]]; then
    # shellcheck disable=SC2059
    ui::warn "$(printf "${MSG_DELETE_GIT_WARN:-'%s' has uncommitted changes and will be lost permanently.}" "$path")"
  fi
}

cmd_delete::run() {
  if [[ $# -eq 0 ]]; then
    cmd_help::run_subcmd "delete"
    return 0
  fi

  case "$1" in
    profile)
      shift
      if [[ $# -eq 0 ]]; then
        ui::error "${MSG_DELETE_PROFILE_MISSING:---profile / -p requires a name}"
        exit 2
      fi
      _delete_profile "$1"
      ;;
    -*)
      # shellcheck disable=SC2059
      ui::error "$(printf "${MSG_UNKNOWN_FLAG:-Unknown flag: %s}" "$1")"
      exit 2
      ;;
    *)
      _delete_package "$1"
      ;;
  esac
}

_delete_package() {
  local pkg="$1"
  local dots_dir
  dots_dir="$(repo::resolve_dir)"
  local pkg_dir="${dots_dir}/${pkg}"

  if [[ ! -d "$pkg_dir" ]]; then
    # shellcheck disable=SC2059
    ui::error "$(printf "${MSG_PKG_NOT_FOUND:-Package not found: %s}" "$pkg")"
    exit 1
  fi

  _delete_git_check "$dots_dir" "$pkg_dir"

  if _delete_pkg_is_linked "$pkg_dir"; then
    # shellcheck disable=SC2059
    ui::warn "$(printf "${MSG_DELETE_PKG_LINKED:-Package '%s' is currently linked. Unlinking first...}" "$pkg")"
    local _err
    if ! _err="$(stow -d "$dots_dir" -t "$HOME" -D "$pkg" 2>&1)"; then
      printf '%s\n' "$_err" >&2
    fi
  fi

  if [[ "${DFY_YES:-0}" != "1" ]]; then
    printf '\n'
    # shellcheck disable=SC2059
    ui::ask "$(printf "${MSG_DELETE_PKG_CONFIRM:-Delete package '%s'? [y/N] }" "$pkg")"
    local answer
    read -r answer || true
    printf '\n'
    if [[ "$answer" != [YySs] ]]; then
      ui::info "${MSG_DELETE_ABORTED:-Aborted.}"
      return 0
    fi
  fi

  rm -rf "$pkg_dir"
  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_DELETE_PKG_OK:-Deleted package: %s}" "$pkg")"
}

_delete_profile() {
  local name="$1"
  local profiles_dir
  profiles_dir="$(profile::dir)"
  local profile_file="${profiles_dir}/${name}.txt"

  if [[ ! -f "$profile_file" ]]; then
    # shellcheck disable=SC2059
    ui::error "$(printf "${MSG_PROFILE_NOT_FOUND:-Profile not found: %s}" "$name")"
    exit 1
  fi

  local dots_dir
  dots_dir="$(repo::resolve_dir)"
  _delete_git_check "$dots_dir" "$profile_file"

  if [[ "${DFY_YES:-0}" != "1" ]]; then
    printf '\n'
    # shellcheck disable=SC2059
    ui::ask "$(printf "${MSG_DELETE_PROFILE_CONFIRM:-Delete profile '%s'? [y/N] }" "$name")"
    local answer
    read -r answer || true
    printf '\n'
    if [[ "$answer" != [YySs] ]]; then
      ui::info "${MSG_DELETE_ABORTED:-Aborted.}"
      return 0
    fi
  fi

  rm "$profile_file"
  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_DELETE_PROFILE_OK:-Deleted profile: %s}" "$name")"
}
