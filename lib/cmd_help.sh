# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Full help output: banner + usage table.
cmd_help::run() {
  ui::banner "OpenDots"
  printf '\n'
  printf '%s\n' "${MSG_HELP_USAGE}"
  printf '\n'
  printf '%s\n' "${MSG_HELP_SUBCMDS_HEADER}"
  printf '  %-10s %s\n' "install" "${MSG_SUBCMD_INSTALL}"
  printf '  %-10s %s\n' "remove" "${MSG_SUBCMD_REMOVE}"
  printf '  %-10s %s\n' "adopt" "${MSG_SUBCMD_ADOPT}"
  printf '  %-10s %s\n' "list" "${MSG_SUBCMD_LIST}"
  printf '  %-10s %s\n' "status" "${MSG_SUBCMD_STATUS}"
  printf '  %-10s %s\n' "doctor" "${MSG_SUBCMD_DOCTOR}"
  printf '  %-10s %s\n' "help" "${MSG_SUBCMD_HELP}"
  printf '\n'
  printf '%s\n' "${MSG_HELP_OPTS_HEADER}"
  printf '  %-22s %s\n' "--help, -h" "${MSG_OPT_HELP}"
  printf '  %-22s %s\n' "--version, -V" "${MSG_OPT_VERSION}"
  printf '  %-22s %s\n' "--no-color" "${MSG_OPT_NO_COLOR}"
  printf '  %-22s %s\n' "--dry-run" "${MSG_OPT_DRY_RUN}"
  printf '  %-22s %s\n' "--profile <name>" "${MSG_OPT_PROFILE}"
  printf '  %-22s %s\n' "--dir <path>" "${MSG_OPT_DIR}"
  printf '  %-22s %s\n' "--yes, -y" "${MSG_OPT_YES}"
  printf '  %-22s %s\n' "--lang <code>" "${MSG_OPT_LANG}"
}

# Version line: banner (respects color/figlet rules) + version string.
cmd_help::show_version() {
  ui::banner "OpenDots"
  # shellcheck disable=SC2059
  printf "${MSG_VERSION_LINE}\n" "${OPENDOTS_VERSION}"
}

# Per-subcommand usage (no banner).
cmd_help::run_subcmd() {
  local subcmd="$1"
  case "$subcmd" in
    install) printf '%s\n' "${MSG_HELP_INSTALL}" ;;
    remove) printf '%s\n' "${MSG_HELP_REMOVE}" ;;
    adopt) printf '%s\n' "${MSG_HELP_ADOPT}" ;;
    list) printf '%s\n' "${MSG_HELP_LIST}" ;;
    status) printf '%s\n' "${MSG_HELP_STATUS}" ;;
    doctor) printf '%s\n' "${MSG_HELP_DOCTOR}" ;;
    help) cmd_help::run ;;
    *)
      # shellcheck disable=SC2059
      printf "${MSG_UNKNOWN_SUBCMD:-Unknown subcommand: '%s'}\n" "$subcmd" >&2
      printf '%s\n' "${MSG_USAGE_HINT:-Run 'dots --help' for usage.}" >&2
      exit 2
      ;;
  esac
}
