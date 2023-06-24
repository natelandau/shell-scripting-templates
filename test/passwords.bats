#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

#ROOTDIR="$(git rev-parse --show-toplevel)"
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY"; }

######## FIXTURES ########
unencrypted="${BATS_TEST_DIRNAME}/fixtures/test.md"
encrypted="${BATS_TEST_DIRNAME}/fixtures/test.md.enc"

######## SETUP TESTS ########
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

@test "bfl::generate_UUID" {
    run bfl::generate_UUID
    assert_success
    assert_output --regexp "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
}

@test "bfl::decrypt_file" {
  run bfl::decrypt_file "${encrypted}" "test-decrypted.md"
  assert_success
  assert_file_exist "test-decrypted.md"
  run cat "test-decrypted.md"
  assert_success
  assert_line --index 0 "# About"
  assert_line --index 1 "This repository contains everything needed to bootstrap and configure new Mac computer. Included here are:"
}

@test "bfl::encrypt_file" {
  run bfl::encrypt_file "${unencrypted}" "test-encrypted.md.enc"
  assert_success
  assert_file_exist "test-encrypted.md.enc"
  run cat "test-encrypted.md.enc"
  assert_line --index 0 --partial "Salted__"
}
