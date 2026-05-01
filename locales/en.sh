# SPDX-License-Identifier: GPL-3.0-or-later

# Error messages
MSG_BASH_TOO_OLD="dfy requires bash >= 4 (found: %s). Please upgrade."
MSG_UNKNOWN_FLAG="Unknown flag: %s"
MSG_UNKNOWN_SUBCMD="Unknown subcommand: '%s'"
MSG_SUGGEST_SUBCMD="  Did you mean: %s"
MSG_USAGE_HINT="Run 'dfy --help' for usage."
MSG_NOT_IMPLEMENTED="%s: not implemented yet."

# Help — structural labels
MSG_HELP_USAGE="Usage: dfy [options] <subcommand> [args]"
MSG_HELP_SUBCMDS_HEADER="Subcommands:"
MSG_HELP_OPTS_HEADER="Global options:"

# Subcommand one-liners
MSG_SUBCMD_INSTALL="Stow packages from your dotfiles repo"
MSG_SUBCMD_REMOVE="Unstow packages"
MSG_SUBCMD_ADOPT="Adopt an existing file into a package"
MSG_SUBCMD_LIST="List available packages"
MSG_SUBCMD_STATUS="Show stow status"
MSG_SUBCMD_DOCTOR="Check system health"
MSG_SUBCMD_UPDATE="Update Dotlify to the latest version"
MSG_SUBCMD_UNINSTALL="Remove Dotlify from this system"
MSG_SUBCMD_HELP="Show this help message"

# Option descriptions
MSG_OPT_HELP="Show this help message"
MSG_OPT_VERSION="Show version"
MSG_OPT_NO_COLOR="Disable color output"
MSG_OPT_DRY_RUN="Simulate without applying changes"
MSG_OPT_PROFILE="Use named profile"
MSG_OPT_DIR="Dotfiles directory (default: ~/.dotfiles)"
MSG_OPT_YES="Auto-confirm prompts"
MSG_OPT_LANG="Override language (en, es)"

# Per-subcommand usage lines
MSG_HELP_INSTALL="Usage: dfy install <package...>"
MSG_HELP_REMOVE="Usage: dfy remove <package...>"
MSG_HELP_ADOPT="Usage: dfy adopt <package>"
MSG_HELP_LIST="Usage: dfy list"
MSG_HELP_STATUS="Usage: dfy status"
MSG_HELP_DOCTOR="Usage: dfy doctor"
MSG_HELP_UPDATE="Usage: dfy update"
MSG_HELP_UNINSTALL="Usage: dfy uninstall"

# repo.sh
MSG_REPO_NOT_FOUND="Dotfiles directory not found: %s"
MSG_REPO_HINT="Create it, set DFY_DIR, or pass --dir <path>."

# cmd_install.sh
MSG_PKG_NOT_FOUND="Package not found: %s"
MSG_INSTALL_CONFLICT="Conflict: target file already exists (not a symlink):"
MSG_INSTALL_ADOPT_HINT="Run 'dfy adopt <package>' to adopt existing files."
MSG_INSTALL_OK="Installed: %s"

# cmd_remove.sh
MSG_REMOVE_OK="Removed: %s"

# cmd_adopt.sh
MSG_ADOPT_PREVIEW="The following files will be moved into the package:"
MSG_ADOPT_CONFIRM="Proceed? [y/N] "
MSG_ADOPT_ABORTED="Aborted."
MSG_ADOPT_NOTHING="Nothing to adopt for package: %s"
MSG_ADOPT_OK="Adopted: %s"

# cmd_list.sh
MSG_LIST_EMPTY="No packages found in %s"

# cmd_status.sh
MSG_STATUS_DOTFILES="Dotfiles: %s"
MSG_STATUS_LINKED="Linked packages (%s):"
MSG_STATUS_CONFLICTS="Conflicts (%s):"
MSG_STATUS_NONE="No packages found."
MSG_STATUS_CONFLICT_HINT="target exists, run: dfy adopt"

# profile.sh
MSG_PROFILE_NOT_FOUND="Profile not found: %s"
MSG_PROFILE_AVAILABLE="Available profiles: %s"
MSG_PROFILE_NONE="No profiles defined."
MSG_STATUS_PROFILE="Active profile: %s"
MSG_STATUS_NO_PROFILE="(no active profile)"

# cmd_doctor.sh
MSG_DOCTOR_OK="Everything looks good."
MSG_DOCTOR_ISSUES="%s issue(s) found."
MSG_DOCTOR_STOW_MISSING="stow is not installed."
MSG_DOCTOR_BASH_OLD="bash < 4.0 detected (found: %s)"
MSG_DOCTOR_STOW_OLD="stow < 2.3.1 detected (found: %s)"
MSG_DOCTOR_BROKEN_LINK="Broken symlink: %s"

# cmd_update.sh
MSG_UPDATE_PULLING="Pulling latest changes..."
MSG_UPDATE_COMP="Updating shell completions..."
MSG_UPDATE_OK="Dotlify updated successfully."
MSG_UPDATE_NOT_GIT="Not a git repository, cannot update: %s"

# cmd_uninstall.sh
MSG_UNINSTALL_CONFIG="Remove config directory %s? [y/N] "
MSG_UNINSTALL_CONFIG_KEPT="Kept: %s"
MSG_UNINSTALL_CLONE="Remove clone directory %s? [y/N] "
MSG_UNINSTALL_OK="Dotlify uninstalled."
