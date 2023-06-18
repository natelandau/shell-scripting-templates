#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

#ROOTDIR="$(git rev-parse --show-toplevel)"
[[ $_GUARD_BFL_autoload -ne 1 ]] && . /etc/getConsts && . "$BASH_FUNCTION_LIBRARY" # подключаем внешнюю "библиотеку"

######## SETUP TESTS ########
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

@test "bfl::_is_natural_number: true " {
  testVar="123"
  run bfl::_is_natural_number "${testVar}"
  assert_success
}

@test "bfl::_is_natural_number: false " {
  testVar="12 3"
  run bfl::_is_natural_number "${testVar}"
  assert_failure
}
