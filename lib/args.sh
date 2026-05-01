# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Globals populated by args::parse_global — exported so consumers see them.
# Env-var forms of DFY_DIR / DFY_PROFILE / DFY_LANG are preserved when not
# overridden by flags, so users can set them in their shell profile.
export DFY_SHOW_HELP=0
export DFY_SHOW_VERSION=0
export DFY_DRY_RUN="${DFY_DRY_RUN:-0}"
export DFY_YES="${DFY_YES:-0}"
export DFY_PROFILE="${DFY_PROFILE:-}"
export DFY_DIR="${DFY_DIR:-}"
export DFY_LANG="${DFY_LANG:-}"
export DFY_SUBCMD=""
# shellcheck disable=SC2034  # read by bin/dfy after args::parse_global returns
DFY_SUBCMD_ARGS=()

_ARGS_KNOWN_SUBCMDS=(link unlink adopt list status doctor update uninstall info create delete init config help)

# Parse global flags from "$@".
# Global flags are accepted in any position — before or after the subcommand.
# Unknown flags before the subcommand cause an error.
# Unknown flags after the subcommand are forwarded to the subcommand via
# DFY_SUBCMD_ARGS so subcommand-specific flags (e.g. --bare) still work.
args::parse_global() {
  DFY_SHOW_HELP=0
  DFY_SHOW_VERSION=0
  DFY_SUBCMD=""
  DFY_SUBCMD_ARGS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help | -h)
        DFY_SHOW_HELP=1
        shift
        ;;
      --version | -V)
        DFY_SHOW_VERSION=1
        shift
        ;;
      --no-color)
        export DFY_NO_COLOR=1
        export THEME_COLORS_ENABLED=0
        shift
        ;;
      --dry-run)
        DFY_DRY_RUN=1
        shift
        ;;
      --yes | -y)
        DFY_YES=1
        shift
        ;;
      --profile | -p)
        shift
        if [[ $# -eq 0 ]]; then
          _args_flag_needs_value "--profile / -p"
        fi
        DFY_PROFILE="$1"
        shift
        ;;
      --dir | -d)
        shift
        if [[ $# -eq 0 ]]; then
          _args_flag_needs_value "--dir / -d"
        fi
        DFY_DIR="$1"
        shift
        ;;
      --lang | -l)
        shift
        if [[ $# -eq 0 ]]; then
          _args_flag_needs_value "--lang / -l"
        fi
        DFY_LANG="$1"
        shift
        ;;
      --* | -*)
        if [[ -n "$DFY_SUBCMD" ]]; then
          # Forward unknown flags to the subcommand (e.g. --bare for init).
          DFY_SUBCMD_ARGS+=("$1")
        else
          _args_unknown_flag "$1"
        fi
        shift
        ;;
      *)
        if [[ -z "$DFY_SUBCMD" ]]; then
          DFY_SUBCMD="$1"
        else
          DFY_SUBCMD_ARGS+=("$1")
        fi
        shift
        ;;
    esac
  done
}

_args_flag_needs_value() {
  # shellcheck disable=SC2059
  printf "${MSG_UNKNOWN_FLAG:-Unknown flag: %s}\n" "$1 requires a value" >&2
  printf '%s\n' "${MSG_USAGE_HINT:-Run 'dfy --help' for usage.}" >&2
  exit 2
}

_args_unknown_flag() {
  # shellcheck disable=SC2059
  printf "${MSG_UNKNOWN_FLAG:-Unknown flag: %s}\n" "$1" >&2
  printf '%s\n' "${MSG_USAGE_HINT:-Run 'dfy --help' for usage.}" >&2
  exit 2
}

# Return the first known subcommand that starts with <input>, or nothing.
_args_suggest_subcmd() {
  local input="$1" cmd
  for cmd in "${_ARGS_KNOWN_SUBCMDS[@]}"; do
    if [[ "$cmd" == "${input}"* ]]; then
      printf '%s' "$cmd"
      return
    fi
  done
}

# Dispatch to the right cmd_*::run function.
# Handles per-subcommand --help before delegating.
args::dispatch() {
  local subcmd="$1"
  shift
  local -a subcmd_args=("$@")

  local arg
  for arg in "${subcmd_args[@]+"${subcmd_args[@]}"}"; do
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
      cmd_help::run_subcmd "$subcmd"
      return 0
    fi
  done

  case "$subcmd" in
    link) cmd_link::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    unlink) cmd_unlink::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    adopt) cmd_adopt::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    list) cmd_list::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    status) cmd_status::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    doctor) cmd_doctor::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    update) cmd_update::run ;;
    uninstall) cmd_uninstall::run ;;
    info) cmd_info::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    create) cmd_create::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    delete) cmd_delete::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    init) cmd_init::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    config) cmd_config::run "${subcmd_args[@]+"${subcmd_args[@]}"}" ;;
    help)
      if [[ ${#subcmd_args[@]} -gt 0 ]]; then
        cmd_help::run_subcmd "${subcmd_args[0]}"
      else
        cmd_help::run
      fi
      ;;
    *)
      local suggestion
      suggestion="$(_args_suggest_subcmd "$subcmd")"
      # shellcheck disable=SC2059
      printf "${MSG_UNKNOWN_SUBCMD:-Unknown subcommand: '%s'}\n" "$subcmd" >&2
      if [[ -n "$suggestion" ]]; then
        # shellcheck disable=SC2059
        printf "${MSG_SUGGEST_SUBCMD:-  Did you mean: %s}\n" "$suggestion" >&2
      fi
      printf '%s\n' "${MSG_USAGE_HINT:-Run 'dfy --help' for usage.}" >&2
      exit 2
      ;;
  esac
}
