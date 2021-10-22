#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/arrays.bash"
BASEHELPERS="${ROOTDIR}/utilities/misc.bash"
ALERTS="${ROOTDIR}/utilities/alerts.bash"
CHECKS="${ROOTDIR}/utilities/checks.bash"

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

if test -f "${CHECKS}" >&2; then
  source "${CHECKS}"
else
  echo "Sourcefile not found: ${CHECKS}" >&2
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
  run _inArray_ "one" "${A[@]}"
  assert_success
}

@test "_inArray_: success and ignore case" {
  run _inArray_ -i "ONE" "${A[@]}"
  assert_success
}

@test "_inArray_: failure" {
  run _inArray_ ten "${A[@]}"
  assert_failure
}

@test "_joinArray_: Join array comma" {
  run _joinArray_ , "${B[@]}"
  assert_success
  assert_output "1,2,3,4,5,6"
}

@test "_joinArray_: Join array space" {
  run _joinArray_ " " "${B[@]}"
  assert_success
  assert_output "1 2 3 4 5 6"
}

@test "_joinArray_: Join string complex" {
  run _joinArray_ , a "b c" d
  assert_success
  assert_output "a,b c,d"
}

@test "_joinArray_: join string simple" {
  run _joinArray_ / var usr tmp
  assert_success
  assert_output "var/usr/tmp"
}

@test "_setDiff_: Print elements not common to arrays" {
  run _setDiff_ "A[@]" "B[@]"
  assert_success
  assert_line --index 0 "one"
  assert_line --index 1 "two"
  assert_line --index 2 "three"

  run _setDiff_ "B[@]" "A[@]"
  assert_success
  assert_line --index 0 "4"
  assert_line --index 1 "5"
  assert_line --index 2 "6"
}

@test "_setDiff_: Fail when no diff" {
  run _setDiff_ "A[@]" "A[@]"
  assert_failure
}

@test "_randomArrayElement_" {
  run _randomArrayElement_ "${A[@]}"
  assert_success
  assert_output --regexp '^one|two|three|1|2|3$'
}

@test "_dedupeArray_: remove duplicates" {
  run _dedupeArray_ "${DUPES[@]}"
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
}

@test "_isEmptyArray_: empty" {
  declare -a emptyArray=()
  run _isEmptyArray_ "${emptyArray[@]}"
  assert_success
}

@test "_isEmptyArray_: not empty" {
  fullArray=(1 2 3)
  run _isEmptyArray_ "${fullArray[@]}"
  assert_failure
}

@test "_sortArray_" {
  unsorted_array=("c" "b" "c" "4" "1" "3" "a" "2" "d")
  run _sortArray_ "${unsorted_array[@]}"
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
  assert_line --index 3 "4"
  assert_line --index 4 "a"
  assert_line --index 5 "b"
  assert_line --index 6 "c"
  assert_line --index 7 "c"
  assert_line --index 8 "d"
}

@test "_reverseSortArray_" {
  unsorted_array=("c" "b" "c" "4" "1" "3" "a" "2" "d")
  run _reverseSortArray_ "${unsorted_array[@]}"
  assert_success
  assert_line --index 0 "d"
  assert_line --index 1 "c"
  assert_line --index 2 "c"
  assert_line --index 3 "b"
  assert_line --index 4 "a"
  assert_line --index 5 "4"
  assert_line --index 6 "3"
  assert_line --index 7 "2"
  assert_line --index 8 "1"
}

@test "_mergeArrays_" {
  a1=(1 2 3)
  a2=(3 2 1)
  run _mergeArrays_ "a1[@]" "a2[@]"
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
  assert_line --index 3 "3"
  assert_line --index 4 "2"
  assert_line --index 5 "1"
}


@test "_forEachDo_" {
  test_func() {
      printf "print value: %s\n" "$1"
      return 0
    }
  array=(1 2 3 4 5)

  run _forEachDo_ "test_func" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_line --index 0 "print value: 1"
  assert_line --index 1 "print value: 2"
  assert_line --index 2 "print value: 3"
  assert_line --index 3 "print value: 4"
  assert_line --index 4 "print value: 5"
}

@test "_forEachValidate_: success" {
  array=("a" "abcdef" "ppll" "xyz")

  run _forEachValidate_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_success
}

@test "_forEachValidate_: failure" {
  array=("a" "abcdef" "ppll99" "xyz")

  run _forEachValidate_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_failure
}

@test "_forEachFind_: success" {
  array=("1" "234" "success" "45p9")

  run _forEachFind_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_output "success"
}

@test "_forEachFind_: failure" {
  array=("1" "2" "3" "4")

  run _forEachFind_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_failure
}

@test "_forEachFilter_" {
  array=(1 2 3 a ab 5 cde 6)

  run _forEachFilter_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_line --index 0 "a"
  assert_line --index 1 "ab"
  assert_line --index 2 "cde"
}

@test "_forEachReject_" {
  array=(1 2 3 a ab 5 cde 6)

  run _forEachReject_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
  assert_line --index 3 "5"
  assert_line --index 4 "6"
}

@test "_forEachSome_: success" {
  array=("1" "234" "success" "45p9")

  run _forEachSome_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_success
}

@test "_forEachSome_: failure" {
  array=("1" "2" "3" "4")

  run _forEachSome_ "_isAlpha_" < <(printf "%s\n" "${array[@]}")
  assert_failure
}
