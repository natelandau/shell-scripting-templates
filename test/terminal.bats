#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/terminal
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY"; }


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #
load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

#ROOTDIR="$(git rev-parse --show-toplevel)"

# **************************************************************************** #
# Setup tests                                                                  #
# **************************************************************************** #
setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" >&2

  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  BASH_INTERACTIVE=true
  LOGLEVEL=ERROR
  VERBOSE=false
  FORCE=false
  DRYRUN=false

#  _setColors_ # Set Color Constants

  set -o errtrace
  set -o nounset
  set -o pipefail
}

teardown() {
  set +o nounset
  set +o errtrace
  set +o pipefail

  popd >&2
  temp_del "${TESTDIR}"
}

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

# ---------------------------------------------------------------------------- #
# bfl::terminal_print_2columns                                                 #
# ---------------------------------------------------------------------------- #
@test "bfl::terminal_print_2columns: key/value" {
  run bfl::terminal_print_2columns "key" "value"
  assert_output --regexp "^key.*value"
}

@test "bfl::terminal_print_2columns: indented key/value" {
  run bfl::terminal_print_2columns "key" "value" 1
  assert_output --regexp "^  key.*value"
}

# ---------------------------------------------------------------------------- #
# bfl::terminal_spinner                                                        #
# ---------------------------------------------------------------------------- #
@test "bfl::terminal_spinner: verbose" {
    verbose=true
    run bfl::terminal_spinner
    assert_success
    assert_output ""
}

@test "bfl::terminal_spinner: quiet" {
    quiet=true
    run bfl::terminal_spinner
    assert_success
    assert_output ""
}

# ---------------------------------------------------------------------------- #
# bfl::terminal_progressbar                                                    #
# ---------------------------------------------------------------------------- #
@test "bfl::terminal_progressbar: verbose" {
    verbose=true
    run bfl::terminal_progressbar 100
    assert_success
    assert_output ""
}

@test "bfl::terminal_progressbar: quiet" {
    quiet=true
    run bfl::terminal_progressbar 100
    assert_success
    assert_output ""
}
