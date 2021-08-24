#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/numbers.bash"
BASEHELPERS="${ROOTDIR}/utilities/baseHelpers.bash"
ALERTS="${ROOTDIR}/utilities/alerts.bash"

if test -f "${SOURCEFILE}" >&2; then
  source "${SOURCEFILE}"
else
  echo "Sourcefile not found: ${SOURCEFILE}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

if test -f "${ALERTS}" >&2; then
  source "${ALERTS}"
  _setColors_ #Set color constants
else
  echo "Sourcefile not found: ${ALERTS}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

if test -f "${BASEHELPERS}" >&2; then
  source "${BASEHELPERS}"
else
  echo "Sourcefile not found: ${BASEHELPERS}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" &>/dev/null

  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  QUIET=false
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

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "_convertSecs_: Seconds to human readable" {

  run _fromSeconds_ "9255"
  assert_success
  assert_output "02:34:15"
}

@test "_toSeconds_: HH MM SS to Seconds" {
  run _toSeconds_ 12 3 33
  assert_success
  assert_output "43413"
}

@test "_countdown_: custom message, default wait" {
  run _countdown_ 10 0 "something"
  assert_line --index 0 --partial "something 10"
  assert_line --index 9 --partial "something 1"
}

@test "_countdown_: default message, custom wait" {
  run _countdown_ 5 0
  assert_line --index 0 --partial "... 5"
  assert_line --index 4 --partial "... 1"
}

@test "_countdown_: all defaults" {
  run _countdown_
  assert_line --index 0 --partial "... 10"
  assert_line --index 9 --partial "... 1"
}
