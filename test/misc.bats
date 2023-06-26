#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

#ROOTDIR="$(git rev-parse --show-toplevel)"
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY"; }

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

@test "bfl::execute: Debug command" {
    DRYRUN=true
    run bfl::execute "rm testfile.txt"
    assert_success
    assert_output --partial "[ dryrun] rm testfile.txt"
}

@test "bfl::execute: No command" {
    run bfl::execute

    assert_failure
    assert_output --regexp "\[  fatal\] Missing required argument to bfl::execute"
}

@test "bfl::execute: Bad command" {
    run bfl::execute "rm nonexistant.txt"

    assert_failure
    assert_output --partial "[warning] rm nonexistant.txt"
}

@test "bfl::execute -e: Bad command" {
    run bfl::execute -e "rm nonexistant.txt"

    assert_failure
    assert_output "error: rm nonexistant.txt"
}

@test "bfl::execute -p: Return 0 on bad command" {
    run bfl::execute -p "rm nonexistant.txt"
    assert_success
    assert_output --partial "[warning] rm nonexistant.txt"
}

@test "bfl::execute: Good command" {
    touch "testfile.txt"
    run bfl::execute "rm testfile.txt"
    assert_success
    assert_output --partial "[   info] rm testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "bfl::execute: Good command - no output" {
    touch "testfile.txt"
    run bfl::execute -q "rm testfile.txt"
    assert_success
    refute_output --partial "[   info] rm testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "bfl::execute -s: Good command" {
    touch "testfile.txt"
    run bfl::execute -s "rm testfile.txt"
    assert_success
    assert_output --partial "[success] rm testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "bfl::execute -v: Good command" {
    touch "testfile.txt"
    run bfl::execute -v "rm -v testfile.txt"

    assert_success
    assert_line --index 0 "removed 'testfile.txt'"
    assert_line --index 1 --partial "[   info] rm -v testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "bfl::execute -n: Good command" {
    touch "testfile.txt"
    run bfl::execute -n "rm -v testfile.txt"

    assert_success
    assert_line --index 0 --partial "[ notice] rm -v testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "bfl::execute -ev: Good command" {
    touch "testfile.txt"
    run bfl::execute -ve "rm -v testfile.txt"

    assert_success
    assert_line --index 0 "removed 'testfile.txt'"
    assert_line --index 1 --partial "rm -v testfile.txt"
    assert_file_not_exist "testfile.txt"
}
