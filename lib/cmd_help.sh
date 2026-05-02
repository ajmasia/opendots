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
  printf '%s%s%s %s%s%s\n' \
    "$(theme::accent)" "${MSG_HELP_USAGE_LABEL}" "$(theme::reset)" \
    "$(theme::subtext)" "${MSG_HELP_USAGE_BODY}" "$(theme::reset)"
  printf '\n'
  _help_section "${MSG_HELP_SUBCMDS_HEADER}"
  _help_cmd_row "link" "${MSG_SUBCMD_LINK}"
  _help_cmd_row "unlink" "${MSG_SUBCMD_UNLINK}"
  _help_cmd_row "adopt" "${MSG_SUBCMD_ADOPT}"
  _help_cmd_row "list" "${MSG_SUBCMD_LIST}"
  _help_cmd_row "info" "${MSG_SUBCMD_INFO}"
  _help_cmd_row "create" "${MSG_SUBCMD_CREATE}"
  _help_cmd_row "delete" "${MSG_SUBCMD_DELETE}"
  _help_cmd_row "init" "${MSG_SUBCMD_INIT}"
  _help_cmd_row "config" "${MSG_SUBCMD_CONFIG}"
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
  _help_opt_row "--profile, -p <name>" "${MSG_OPT_PROFILE}"
  _help_opt_row "--dir, -d <path>" "${MSG_OPT_DIR}"
  _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
  _help_opt_row "--lang, -l <code>" "${MSG_OPT_LANG}"
}

# Version line: banner (respects color/figlet rules) + version string.
cmd_help::show_version() {
  ui::banner "Dotlify"
  printf '%sv%s%s %s(GPL-3.0-or-later)%s\n' \
    "$(theme::info)" "${DOTLIFY_VERSION}" "$(theme::reset)" \
    "$(theme::muted)" "$(theme::reset)"
}

# Per-subcommand usage (no banner).

_help_usage_line() {
  printf '%s%s%s %s%s%s\n' \
    "$(theme::accent)" "${MSG_HELP_USAGE_LABEL:-Usage:}" "$(theme::reset)" \
    "$(theme::text)" "$1" "$(theme::reset)"
}

_help_desc_line() {
  printf '%s%s%s\n' "$(theme::subtext)" "$1" "$(theme::reset)"
}

cmd_help::run_subcmd() {
  local subcmd="$1"
  local _opts_header="${MSG_HELP_SUBCMD_OPTS_HEADER:-Options:}"
  case "$subcmd" in
    link)
      _help_usage_line "dfy link <package...> [--profile <name>]"
      _help_desc_line "${MSG_SUBCMD_LINK}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "--profile, -p <name>" "${MSG_OPT_PROFILE}"
      _help_opt_row "--dry-run" "${MSG_OPT_DRY_RUN}"
      _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
      ;;
    unlink)
      _help_usage_line "dfy unlink <package...> [--profile <name>]"
      _help_desc_line "${MSG_SUBCMD_UNLINK}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "--profile, -p <name>" "${MSG_OPT_PROFILE}"
      ;;
    adopt)
      _help_usage_line "dfy adopt <package>"
      _help_desc_line "${MSG_SUBCMD_ADOPT}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
      ;;
    list)
      _help_usage_line "dfy list"
      _help_desc_line "${MSG_SUBCMD_LIST}"
      ;;
    info)
      _help_usage_line "dfy info <package>"
      _help_desc_line "${MSG_SUBCMD_INFO}"
      ;;
    create)
      _help_usage_line "dfy create <package> [-s <subdir>]"
      _help_desc_line "${MSG_SUBCMD_CREATE}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "-s, --subdir <path>" "${MSG_HELP_OPT_SUBDIR}"
      _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
      ;;
    delete)
      _help_usage_line "dfy delete <package> | profile <name>"
      _help_desc_line "${MSG_SUBCMD_DELETE}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
      ;;
    init)
      _help_usage_line "dfy init [--dir <path>] [--bare]"
      _help_desc_line "${MSG_SUBCMD_INIT}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "--dir, -d <path>" "${MSG_OPT_DIR}"
      _help_opt_row "--bare" "${MSG_HELP_OPT_BARE}"
      _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
      ;;
    config)
      _help_usage_line "dfy config get <key> | set <key> <value> | list | edit"
      _help_desc_line "${MSG_SUBCMD_CONFIG}"
      ;;
    status)
      _help_usage_line "dfy status [--profile <name>]"
      _help_desc_line "${MSG_SUBCMD_STATUS}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "--profile, -p <name>" "${MSG_OPT_PROFILE}"
      ;;
    doctor)
      _help_usage_line "dfy doctor"
      _help_desc_line "${MSG_SUBCMD_DOCTOR}"
      ;;
    update)
      _help_usage_line "dfy update"
      _help_desc_line "${MSG_SUBCMD_UPDATE}"
      ;;
    uninstall)
      _help_usage_line "dfy uninstall"
      _help_desc_line "${MSG_SUBCMD_UNINSTALL}"
      printf '\n'
      _help_section "$_opts_header"
      _help_opt_row "--yes, -y" "${MSG_OPT_YES}"
      ;;
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
}
