#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/numbers
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

  pushd "${TESTDIR}" &>/dev/null

  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  BASH_INTERACTIVE=true
  LOGLEVEL=OFF
  VERBOSE=false
  FORCE=false
  DRYRUN=false

  set -o errtrace
  set -o nounset
  set -o pipefail
}

teardown() {
  set +o nounset
  set +o errtrace
  set +o pipefail

  popd &>/dev/null
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
# bfl::is_float                                                                #
# ---------------------------------------------------------------------------- #

@test "bfl::is_float -> If STRING is a floating point number, the function should return 0, otherwise 1" {
  run bfl::is_float "1"
  [ "${status}" -eq 0 ]

  run bfl::is_float "0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "+1"
  [ "${status}" -eq 0 ]

  run bfl::is_float "-1"
  [ "${status}" -eq 0 ]

  run bfl::is_float "1.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "0.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "-1.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "+1.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float ""
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------- #
# bfl::is_hex_number                                                           #
# ---------------------------------------------------------------------------- #

@test "bfl::is_hex_number -> If STRING is a hexadecimal, the function should return 0, otherwise 1" {
  run bfl::is_hex_number "1"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "0"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "a"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "A"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "1a"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "a1"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "+1"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number "-1"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number "1.0"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number "g"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# bfl::is_integer                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::is_integer -> If STRING is an integer, the function should return 0, otherwise 1" {
  run bfl::is_integer "1"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "0"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "+1"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "-1"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "1.0"
  [ "${status}" -eq 1 ]

  run bfl::is_integer ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# bfl::is_natural_number                                                       #
# ---------------------------------------------------------------------------- #

@test "bfl::is_natural_number: true " {
  testVar="123"
  run bfl::is_natural_number "${testVar}"
  assert_success
}

@test "bfl::is_natural_number: false " {
  testVar="12 3"
  run bfl::is_natural_number "${testVar}"
  assert_failure
}

@test "bfl::is_natural_number -> If STRING is a natural number, the function should return 0, otherwise 1" {
  run bfl::is_natural_number "1"
  [ "${status}" -eq 0 ]

  run bfl::is_natural_number "0"
  [ "${status}" -eq 0 ]

  run bfl::is_natural_number "-1"
  [ "${status}" -eq 1 ]

  run bfl::is_natural_number "1.0"
  [ "${status}" -eq 1 ]

  run bfl::is_natural_number ""
  [ "${status}" -eq 1 ]
}
