#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/arrays.bash"
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

@test "_inArray_: success" {
  run _inArray_ one "${A[@]}"
  assert_success
}

@test "_inArray_: failure" {
  run _inArray_ ten "${A[@]}"
  assert_failure
}

@test "_join_: Join array comma" {
  run _join_ , "${B[@]}"
  assert_output "1,2,3,4,5,6"
}

@test "_join_: Join array space" {
  run _join_ " " "${B[@]}"
  assert_output "1 2 3 4 5 6"
}

@test "_join_: Join string complex" {
  run _join_ , a "b c" d
  assert_output "a,b c,d"
}

@test "_join_: join string simple" {
  run _join_ / var usr tmp
  assert_output "var/usr/tmp"
}

@test "_setdiff_: Print elements not common to arrays" {
  set +o nounset
  run _setdiff_ "${A[*]}" "${B[*]}"
  assert_output "one two three"

  run _setdiff_ "${B[*]}" "${A[*]}"
  assert_output "4 5 6"
}

@test "_removeDupes_: remove duplicates" {
  set +o nounset
  run _removeDupes_ "${DUPES[@]}"
  assert_line --index 0 "3"
  assert_line --index 1 "2"
  assert_line --index 2 "1"
  assert_line --index 3 ""
}
