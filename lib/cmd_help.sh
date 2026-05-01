# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Row helpers — degrade gracefully when THEME_COLORS_ENABLED=0.

_help_section() {
  printf '%s%s%s\n' "$(theme::accent)" "$1" "$(theme::reset)"
}

_help_cmd_row() {
  local name="$1" desc="$2"
  printf '  %s%-10s%s %s%s%s\n' \
    "$(theme::info)" "$name" "$(theme::reset)" \
    "$(theme::subtext)" "$desc" "$(theme::reset)"
}

_help_opt_row() {
  local flag="$1" desc="$2"
  printf '  %s%-22s%s %s%s%s\n' \
    "$(theme::warning)" "$flag" "$(theme::reset)" \
    "$(theme::subtext)" "$desc" "$(theme::reset)"
}

# Full help output: banner + usage table.
cmd_help::run() {
  ui::banner "Dotlify"
  printf '\n'
  printf '%s%s%s %s\n' \
    "$(theme::accent)" "Usage:" "$(theme::reset)" \
    "$(printf '%sdfy%s [options] <subcommand> [args]' "$(theme::text)" "$(theme::reset)")"
  printf '\n'
  _help_section "${MSG_HELP_SUBCMDS_HEADER}"
  _help_cmd_row "apply" "${MSG_SUBCMD_APPLY}"
  _help_cmd_row "unlink" "${MSG_SUBCMD_UNLINK}"
  _help_cmd_row "adopt" "${MSG_SUBCMD_ADOPT}"
  _help_cmd_row "list" "${MSG_SUBCMD_LIST}"
  _help_cmd_row "info" "${MSG_SUBCMD_INFO}"
  _help_cmd_row "create" "${MSG_SUBCMD_CREATE}"
  _help_cmd_row "status" "${MSG_SUBCMD_STATUS}"
  _help_cmd_row "doctor" "${MSG_SUBCMD_DOCTOR}"
  _help_cmd_row "update" "${MSG_SUBCMD_UPDATE}"
  _help_cmd_row "uninstall" "${MSG_SUBCMD_UNINSTALL}"
  _help_cmd_row "help" "${MSG_SUBCMD_HELP}"
  printf '\n'
  _help_section "${MSG_HELP_OPTS_HEADER}"
  _help_opt_row "--help, -h" "${MSG_OPT_HELP}"
  _help_opt_row "--version, -V" "${MSG_OPT_VERSION}"
  _help_opt_row "--no-color" "${MSG_OPT_NO_COLOR}"
  _help_opt_row "--dry-run" "${MSG_OPT_DRY_RUN}"
  _help_opt_row "--profile <name>" "${MSG_OPT_PROFILE}"
  _help_opt_row "--dir <path>" "${MSG_OPT_DIR}"
  _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
  _help_opt_row "--lang <code>" "${MSG_OPT_LANG}"
}

# Version line: banner (respects color/figlet rules) + version string.
cmd_help::show_version() {
  ui::banner "Dotlify"
  printf '%sv%s%s %s(GPL-3.0-or-later)%s\n' \
    "$(theme::info)" "${DOTLIFY_VERSION}" "$(theme::reset)" \
    "$(theme::muted)" "$(theme::reset)"
}

# Per-subcommand usage (no banner).
cmd_help::run_subcmd() {
  local subcmd="$1"
  local usage
  case "$subcmd" in
    apply) usage="${MSG_HELP_APPLY}" ;;
    unlink) usage="${MSG_HELP_UNLINK}" ;;
    adopt) usage="${MSG_HELP_ADOPT}" ;;
    list) usage="${MSG_HELP_LIST}" ;;
    info) usage="${MSG_HELP_INFO}" ;;
    create) usage="${MSG_HELP_CREATE}" ;;
    status) usage="${MSG_HELP_STATUS}" ;;
    doctor) usage="${MSG_HELP_DOCTOR}" ;;
    update) usage="${MSG_HELP_UPDATE}" ;;
    uninstall) usage="${MSG_HELP_UNINSTALL}" ;;
    help)
      cmd_help::run
      return 0
      ;;
    *)
      # shellcheck disable=SC2059
      printf "${MSG_UNKNOWN_SUBCMD:-Unknown subcommand: '%s'}\n" "$subcmd" >&2
      printf '%s\n' "${MSG_USAGE_HINT:-Run 'dfy --help' for usage.}" >&2
      exit 2
      ;;
  esac
  printf '%s%s%s %s%s%s\n' \
    "$(theme::accent)" "Usage:" "$(theme::reset)" \
    "$(theme::text)" "${usage#Usage: }" "$(theme::reset)"
}
