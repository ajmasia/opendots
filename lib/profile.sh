# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Return the profiles directory for the current dotfiles repo.
profile::dir() {
  local dots_dir
  dots_dir="$(repo::resolve_dir)"
  printf '%s/profiles' "$dots_dir"
}

# Return 0 if profile <name> exists as a .txt file, 1 otherwise.
profile::exists() {
  local name="$1"
  local profiles_dir
  profiles_dir="$(profile::dir)"
  [[ -f "${profiles_dir}/${name}.txt" ]]
}

# Load profile <name>: print one package per line, stripping comments and blanks.
# Exits 2 with an error message if the profile does not exist.
profile::load() {
  local name="$1"
  if ! profile::exists "$name"; then
    # shellcheck disable=SC2059
    printf "${MSG_PROFILE_NOT_FOUND:-Profile not found: %s}\n" "$name" >&2
    local profiles_dir
    profiles_dir="$(profile::dir)"
    local available
    available="$(find "$profiles_dir" -maxdepth 1 -name '*.txt' 2>/dev/null \
      | sed 's|.*/||; s/\.txt$//' | sort | tr '\n' ' ' | sed 's/ $//')"
    if [[ -n "$available" ]]; then
      # shellcheck disable=SC2059
      printf "${MSG_PROFILE_AVAILABLE:-Available profiles: %s}\n" "$available" >&2
    else
      printf '%s\n' "${MSG_PROFILE_NONE:-No profiles defined.}" >&2
    fi
    exit 2
  fi
  local profiles_dir
  profiles_dir="$(profile::dir)"
  local line
  while IFS= read -r line; do
    line="${line%%#*}"              # strip inline comments
    line="${line#"${line%%[! ]*}"}" # ltrim
    line="${line%"${line##*[! ]}"}" # rtrim
    [[ -z "$line" ]] && continue
    printf '%s\n' "$line"
  done <"${profiles_dir}/${name}.txt"
}
