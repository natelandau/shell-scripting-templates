#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
ALERTS="${ROOTDIR}/lib/terminal_functions.bash"

if test -f "${ALERTS}" >&2; then
  source "${ALERTS}"
else
  echo "Sourcefile not found: ${ALERTS}" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi

setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" >&2

  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  QUIET=false
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


######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "bfl::terminal_print_2columns: key/value" {
  run bfl::terminal_print_2columns "key" "value"
  assert_output --regexp "^key.*value"
}

@test "bfl::terminal_print_2columns: indented key/value" {
  run bfl::terminal_print_2columns "key" "value" 1
  assert_output --regexp "^  key.*value"
}

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
