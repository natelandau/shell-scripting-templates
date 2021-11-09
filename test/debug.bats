#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/debug.bash"
BASEHELPERS="${ROOTDIR}/utilities/misc.bash"
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
  PASS=123
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

@test "_printAnsi_" {
  testString="$(tput bold)$(tput setaf 9)This is bold red text$(tput sgr0).$(tput setaf 10)This is green text$(tput sgr0)"
  run _printAnsi_ "${testString}"
  assert_success
  assert_output "\e[1m\e[91mThis is bold red text\e(B\e[m.\e[92mThis is green text\e(B\e[m"
}

@test "_printArray_: Array" {
  testArray=(1 2 3)
  VERBOSE=true
  run _printArray_ "testArray"
  assert_success
  assert_line --index 1 "[  debug] 0 = 1"
  assert_line --index 2 "[  debug] 1 = 2"
  assert_line --index 3 "[  debug] 2 = 3"
}

@test "_printArray_: don't print unless verbose mode" {
  testArray=(1 2 3)
  VERBOSE=false
  run _printArray_ "testArray"
  assert_success
  refute_output --partial "[  debug] 0 = 1"
  refute_output --partial "[  debug] 1 = 2"
  refute_output --partial "[  debug] 2 = 3"
}

@test "_printArray_: Associative array" {
  declare -A assoc_array
  VERBOSE=true
  assoc_array=([foo]=bar [baz]=foobar)
  run _printArray_ "assoc_array"
  assert_success
  assert_line --index 1 "[  debug] foo = bar"
  assert_line --index 2 "[  debug] baz = foobar"
}

@test "_printArray_: print without verbose" {
  testArray=(1 2 3)
  VERBOSE=false
  run _printArray_ -v "testArray"
  assert_success
  assert_output --partial "[   info] 0 = 1"
  assert_output --partial "[   info] 1 = 2"
  assert_output --partial "[   info] 2 = 3"
}
