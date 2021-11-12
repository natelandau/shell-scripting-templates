#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/template_utils.bash"
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

@test "_setPATH_: succeed on dir not found" {
  mkdir -p "${TESTDIR}/testing/from/bats"
  mkdir -p "${TESTDIR}/testing/from/bats_again"
  run _setPATH_ "${TESTDIR}/testing/from/bats" "${TESTDIR}/testing/again" "${TESTDIR}/testing/from/bats_again"
  assert_success
}

@test "_setPATH_: fail on dir not found" {
  mkdir -p "${TESTDIR}/testing/from/bats"
  mkdir -p "${TESTDIR}/testing/from/bats_again"
  run _setPATH_ -x "${TESTDIR}/testing/from/bats" "${TESTDIR}/testing/again" "${TESTDIR}/testing/from/bats_again"
  assert_failure
}

@test "_setPATH_: success" {
  mkdir -p "${TESTDIR}/testing/from/bats"
  mkdir -p "${TESTDIR}/testing/from/bats_again"
  _setPATH_ "${TESTDIR}/testing/from/bats" "${TESTDIR}/testing/from/bats_again"

  run echo "${PATH}"
  assert_output --regexp "/testing/from/bats"
  refute_output --regexp "/testing/again"
  assert_output --regexp "/testing/from/bats_again"
}

@test "_makeTempDir_" {
  VERBOSE=true
  run _makeTempDir_
  assert_success
  assert_output --regexp "\\\$TMP_DIR=/.*\.[0-9]+\.[0-9]+\.[0-9]+$"
}
