# SPDX-License-Identifier: GPL-3.0-or-later

# Error messages
MSG_BASH_TOO_OLD="dfy requires bash >= 4 (found: %s). Please upgrade."
MSG_UNKNOWN_FLAG="Unknown flag: %s"
MSG_UNKNOWN_SUBCMD="Unknown subcommand: '%s'"
MSG_SUGGEST_SUBCMD="  Did you mean: %s"
MSG_USAGE_HINT="Run 'dfy --help' for usage."
MSG_NOT_IMPLEMENTED="%s: not implemented yet."

# Help — structural labels
MSG_HELP_USAGE_LABEL="Usage:"
MSG_HELP_USAGE_BODY="dfy [options] <subcommand> [args]"
MSG_HELP_SUBCMDS_HEADER="Subcommands:"
MSG_HELP_OPTS_HEADER="Global options:"

# Subcommand one-liners
MSG_SUBCMD_LINK="Link packages from your dotfiles repo"
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
MSG_HELP_LINK="Usage: dfy link <package...>"
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

# cmd_apply.sh
MSG_PKG_NOT_FOUND="Package not found: %s"
MSG_APPLY_CONFLICT="Conflict: target file already exists (not a symlink):"
MSG_APPLY_ADOPT_HINT="Run 'dfy adopt <package>' to adopt existing files."
MSG_LINK_OK="Linked: %s"

# cmd_unlink.sh
MSG_UNLINK_OK="Unlinked: %s"
MSG_UNLINK_REPO_HINT="Package files remain in your dotfiles repository."
MSG_SUBCMD_UNLINK="Remove symlinks for packages"
MSG_HELP_UNLINK="Usage: dfy unlink <package...>"

# cmd_adopt.sh
MSG_ADOPT_PREVIEW="The following files will be moved into the package:"
MSG_ADOPT_CONFIRM="Proceed? [y/N] "
MSG_ADOPT_ABORTED="Aborted."
MSG_ADOPT_NOTHING="Nothing to adopt for package: %s"
MSG_ADOPT_OK="Adopted: %s"

# cmd_list.sh
MSG_LIST_EMPTY="No packages found in %s"
MSG_LIST_NO_README="no readme"

# cmd_info.sh
MSG_INFO_NO_README="No README found for %s"
MSG_SUBCMD_INFO="Show a package's README"
MSG_HELP_INFO="Usage: dfy info <package>"

# cmd_create.sh
MSG_CREATE_EXISTS="Package already exists and has a README: %s"
MSG_CREATE_ASK_DESC="Description (optional, Enter to skip): "
MSG_CREATE_DONE="Package scaffolded: %s"
MSG_CREATE_README_DONE="README created for %s"
MSG_CREATE_HINT="Add your config files under %s, then run: dfy link %s"
MSG_CREATE_NEXT_STEPS="Next steps:"
MSG_CREATE_NEXT_ADD="Add dotfiles to %s then run: dfy link %s"
MSG_CREATE_NEXT_ADOPT="Or adopt existing files: dfy adopt %s"
MSG_SUBCMD_CREATE="Scaffold a new package"
MSG_HELP_CREATE="Usage: dfy create <package>"

# cmd_init.sh (subcommand description and usage)
MSG_SUBCMD_INIT="Bootstrap a new dotfiles repository"
MSG_HELP_INIT="Usage: dfy init [--dir, -d <path>] [--bare]"

# cmd_config.sh
MSG_SUBCMD_CONFIG="Read or write Dotlify configuration"
MSG_HELP_CONFIG="Usage: dfy config get <key> | set <key> <value> | list | edit"
MSG_CONFIG_UNKNOWN_VERB="Unknown config verb: %s"
MSG_CONFIG_GET_USAGE="Usage: dfy config get <key>"
MSG_CONFIG_SET_USAGE="Usage: dfy config set <key> <value>"
MSG_CONFIG_SET_OK="Set %s = %s"
MSG_CONFIG_KEY_UNSET="'%s' is not set (default: %s)"
MSG_CONFIG_EDIT_NO_EDITOR="EDITOR is not set. Set it in your shell profile to use 'dfy config edit'."

# cmd_status.sh
MSG_STATUS_DOTFILES="Dotfiles: %s"
MSG_STATUS_LINKED="Linked packages (%s):"
MSG_STATUS_CONFLICTS="Conflicts (%s):"
MSG_STATUS_NOT_LINKED="Not linked (%s):"
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
MSG_UPDATE_NIX="Dotlify is managed by Nix. To upgrade, run:"
MSG_UPDATE_NIX_CMD="  nix profile upgrade dotlify"

# cmd_uninstall.sh
MSG_UNINSTALL_CONFIG="Remove config directory %s? [y/N] "
MSG_UNINSTALL_CONFIG_KEPT="Kept: %s"
MSG_UNINSTALL_CLONE="Remove clone directory %s? [y/N] "
MSG_UNINSTALL_OK="Dotlify uninstalled."
MSG_UNINSTALL_NIX="Dotlify is managed by Nix. To remove, run:"
MSG_UNINSTALL_NIX_CMD="  nix profile remove dotlify"

# cmd_init.sh
MSG_INIT_DIR_EXISTS="Path already exists: %s. Enter an alternative path: "
MSG_INIT_CREATING="Initializing dotfiles repo at %s..."
MSG_INIT_SCAFFOLD="Scaffolding starter files..."
MSG_INIT_REMOTE_HINT="Link your repo to a remote when ready:"
MSG_INIT_DONE="Dotfiles repo ready at %s"
MSG_INIT_NEXT_STEPS="Next steps:"
MSG_INIT_NEXT_REVIEW="  1. Review and personalize the files in %s"
MSG_INIT_NEXT_LINK="  2. Run: dfy apply <package>"
MSG_INIT_NEXT_ADOPT="  3. Or adopt existing files: dfy adopt <file>"
MSG_INIT_CONFIG_OVERWRITE="Config already has dir=%s. Overwrite? [y/N] "

# install.sh
MSG_INSTALL_HINT_INIT="Run 'dfy init' to create your dotfiles repository."

# notify.sh
MSG_NOTIFY_UNCOMMITTED="Your dotfiles repo has uncommitted changes. Run: git -C %s status"
MSG_NOTIFY_IDLE="You haven't used dfy in %d days. Run 'dfy help' to see what's available."

# cmd_delete.sh
MSG_SUBCMD_DELETE="Delete a package or profile"
MSG_HELP_DELETE="Usage: dfy delete <package> | profile <name>"
MSG_DELETE_GIT_WARN="'%s' has uncommitted changes and will be lost permanently."
MSG_DELETE_PKG_LINKED="Package '%s' is currently linked. Unlinking first..."
MSG_DELETE_PKG_CONFIRM="Delete package '%s'? [y/N] "
MSG_DELETE_ABORTED="Aborted."
MSG_DELETE_PKG_OK="Deleted package: %s"
MSG_DELETE_PROFILE_MISSING="--profile / -p requires a name"
MSG_DELETE_PROFILE_CONFIRM="Delete profile '%s'? [y/N] "
MSG_DELETE_PROFILE_OK="Deleted profile: %s"
