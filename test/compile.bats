#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/compile
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
  # Set arrays
  A=(one two three 1 2 3)
  B=(1 2 3 4 5 6)
  DUPES=(1 2 3 1 2 3)

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
# bfl::is_pkg_version                                                          #
# ---------------------------------------------------------------------------- #

@test "bfl::is_pkg_version -> Should return 0, when the STRING matches the pattern 'major.minor.bugfix-suffix'" {
  # Only major component
  run bfl::is_pkg_version "1"
  [ "${status}" -eq 0 ]

  # major and minor components
  run bfl::is_pkg_version "1.0"
  [ "${status}" -eq 0 ]

  # major, minor and bugfix components
  run bfl::is_pkg_version "1.0.0"
  [ "${status}" -eq 0 ]

  # major, minor, bugfx and suffix component
  run bfl::is_pkg_version "1.0.0-SNAPSHOT"
  [ "${status}" -eq 0 ]
}

@test "bfl::is_pkg_version -> Should return 1, when the STRING does not match the pattern 'major.minor.bugfix-suffix'" {
  # major component does not match '[[:digit:]]
  run bfl::is_pkg_version "1a"
  [ "${status}" -eq 1 ]

  # minor component does not match '[[:digit:]]
  run bfl::is_pkg_version "1.0a"
  [ "${status}" -eq 1 ]

  # bugfix component does not match '[[:digit:]]'
  run bfl::is_pkg_version "1.0.0a"
  [ "${status}" -eq 1 ]

  # has more than three version-components
  run bfl::is_pkg_version "1.0.0.0"
  [ "${status}" -eq 1 ]

  # sufix does not match '-[[:alnum:]]'
  run bfl::is_pkg_version "1.0.0-SNAPSHOT-A"
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------- #
# bfl::compare_pkg_versions                                                    #
# ---------------------------------------------------------------------------- #

@test "bfl::compare_pkg_versions -> Should return 0 if VERSION1 is lower than VERSION2." {
  # Simple version numbers
  run bfl::compare_pkg_versions "1.0" "2.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.9" "2.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.0" "1.9"
  [ "$status" -eq 0 ]

  # Version numbers with two digits
  run bfl::compare_pkg_versions "1.0" "1.10"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.10" "2.0"
  [ "$status" -eq 0 ]

  # One version number with bugfix version
  run bfl::compare_pkg_versions "1.0" "2.0.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.0" "1.10.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.0" "1.0.10"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.0.0" "2.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.10.0" "2.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.0.10" "2.0"
  [ "$status" -eq 0 ]

  # Both version numbers with bugfix version
  run bfl::compare_pkg_versions "1.0.0" "2.0.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.10.0" "2.0.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.0.10" "2.0.0"
  [ "$status" -eq 0 ]
  run bfl::compare_pkg_versions "1.0.10" "1.10.0"
  [ "$status" -eq 0 ]
}

@test "bfl::compare_pkg_versions -> Should return 1 if VERSION1 is equal to VERSION2." {
  # Simple version numbers
  run bfl::compare_pkg_versions "1.0" "1.0"
  [ "$status" -eq 1 ]

  # Both version numbers with bugfix version
  run bfl::compare_pkg_versions "1.0.0" "1.0.0"
  [ "$status" -eq 1 ]
}

@test "bfl::compare_pkg_versions -> Should return 2 If VERSION1 is higher than VERSION2." {
  # Simple version numbers
  run bfl::compare_pkg_versions "2.0" "1.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "2.0" "1.9"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "1.9" "1.0"
  [ "$status" -eq 2 ]

  # Version numbers with two digits
  run bfl::compare_pkg_versions "1.10" "1.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "2.0" "1.10"
  [ "$status" -eq 2 ]

  # One version number with bugfix version
  run bfl::compare_pkg_versions "2.0.0" "1.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "1.10.0" "1.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "1.0.10" "1.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "2.0" "1.0.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "2.0" "1.10.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "2.0" "1.0.10"
  [ "$status" -eq 2 ]

  # Both version numbers with bugfix version
  run bfl::compare_pkg_versions "2.0.0" "1.0.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "2.0.0" "1.10.0"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "2.0.0" "1.0.10"
  [ "$status" -eq 2 ]
  run bfl::compare_pkg_versions "1.10.0" "1.0.10"
  [ "$status" -eq 2 ]
}
