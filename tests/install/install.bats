#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../test_helper.bash"
  setup_home
  # shellcheck source=install.sh
  source "${BATS_TEST_DIRNAME}/../../install.sh"

  # Fake bin dir prepended to PATH — mocks record calls to $BATS_TEST_TMPDIR/called
  FAKE_BIN="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$FAKE_BIN"
  _make_mock() {
    local name="$1"
    printf '#!/usr/bin/env bash\nprintf "%%s %%s\n" "%s" "$*" >>"%s/called"\n' \
      "$name" "$BATS_TEST_TMPDIR" >"${FAKE_BIN}/${name}"
    chmod +x "${FAKE_BIN}/${name}"
  }
  _make_mock sudo
  _make_mock apt
  _make_mock pacman
  _make_mock dnf
  _make_mock brew
  export PATH="${FAKE_BIN}:${PATH}"
}

teardown() {
  teardown_dirs
}

# Override install::missing_deps to report specific deps as missing.
_with_missing() {
  local deps="$1"
  shift
  install::missing_deps() {
    local -n _r="$1"
    # shellcheck disable=SC2206
    _r=($deps)
  }
  "$@"
}

# ---------- compose_cmd -------------------------------------------------------

@test "compose_cmd apt returns correct command" {
  run install::compose_cmd apt
  [ "$status" -eq 0 ]
  [ "$output" = "sudo apt install -y stow figlet" ]
}

@test "compose_cmd pacman returns correct command" {
  run install::compose_cmd pacman
  [ "$status" -eq 0 ]
  [ "$output" = "sudo pacman -S --noconfirm stow figlet" ]
}

@test "compose_cmd dnf returns correct command" {
  run install::compose_cmd dnf
  [ "$status" -eq 0 ]
  [ "$output" = "sudo dnf install -y stow figlet" ]
}

@test "compose_cmd brew returns correct command" {
  run install::compose_cmd brew
  [ "$status" -eq 0 ]
  [ "$output" = "brew install stow figlet" ]
}

# ---------- --yes skips prompt ------------------------------------------------

@test "--yes skips prompt and calls package manager" {
  local fixture="${BATS_TEST_TMPDIR}/os-release"
  printf 'ID=ubuntu\n' >"$fixture"
  _OS_RELEASE="$fixture"

  _with_missing "stow figlet" install::deps 1

  local called="${BATS_TEST_TMPDIR}/called"
  [[ -f "$called" ]]
  grep -q "stow" "$called"
}

# ---------- unrecognized distro -----------------------------------------------

@test "unrecognized distro exits 1 with manual-install hint" {
  local fixture="${BATS_TEST_TMPDIR}/os-release"
  printf 'ID=alpine\n' >"$fixture"

  _with_missing "stow" \
    run bash -c "
      source '${BATS_TEST_DIRNAME}/../../install.sh'
      install::missing_deps() { local -n _r=\$1; _r=(stow); }
      _OS_RELEASE='${fixture}' install::deps 1
    "
  [ "$status" -eq 1 ]
  [[ "$output" == *"Install manually"* ]]
}

# ---------- bash version < 4 --------------------------------------------------

@test "bash version < 4 aborts with exit 4" {
  export _INSTALL_BASH_MAJOR=3
  run install::check_bash
  unset _INSTALL_BASH_MAJOR
  [ "$status" -eq 4 ]
  [[ "$output" == *"bash >= 4"* ]]
}

# ---------- stow version < 2.3.1 ----------------------------------------------

@test "stow < 2.3.1 aborts with exit 4" {
  printf '#!/usr/bin/env bash\nprintf "stow (GNU Stow) version 2.2.0\n"\n' \
    >"${FAKE_BIN}/stow"
  chmod +x "${FAKE_BIN}/stow"

  run install::check_stow
  [ "$status" -eq 4 ]
  [[ "$output" == *"stow >= 2.3.1"* ]]
}

# ---------- link_binary -------------------------------------------------------

@test "link_binary creates symlink in ~/.local/bin" {
  local clone="${BATS_TEST_TMPDIR}/clone"
  mkdir -p "${clone}/bin"
  touch "${clone}/bin/dots"

  run install::link_binary "$clone"
  [ "$status" -eq 0 ]
  [[ -L "${HOME}/.local/bin/dots" ]]
  [[ "$(readlink "${HOME}/.local/bin/dots")" == "${clone}/bin/dots" ]]
}

# ---------- completions -------------------------------------------------------

@test "completions installs bash and zsh files" {
  local clone="${BATS_TEST_DIRNAME}/../../"
  run install::completions "$clone"
  [ "$status" -eq 0 ]
  [[ -f "${HOME}/.local/share/bash-completion/completions/dots" ]]
  [[ -f "${HOME}/.local/share/zsh/site-functions/_dots" ]]
}
