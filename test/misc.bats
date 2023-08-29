#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/misc.bash"
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

@test "_execute_: Debug command" {
    DRYRUN=true
    run _execute_ "rm testfile.txt"
    assert_success
    assert_output --partial "[ dryrun] rm testfile.txt"
}

@test "_execute_: No command" {
    run _execute_

    assert_failure
    assert_output --regexp "\[  fatal\] Missing required argument to _execute_"
}

@test "_execute_: Bad command" {
    run _execute_ "rm nonexistent.txt"

    assert_failure
    assert_output --partial "[warning] rm nonexistent.txt"
}

@test "_execute_ -e: Bad command" {
    run _execute_ -e "rm nonexistent.txt"

    assert_failure
    assert_output "error: rm nonexistent.txt"
}

@test "_execute_ -p: Return 0 on bad command" {
    run _execute_ -p "rm nonexistent.txt"
    assert_success
    assert_output --partial "[warning] rm nonexistent.txt"
}

@test "_execute_: Good command" {
    touch "testfile.txt"
    run _execute_ "rm testfile.txt"
    assert_success
    assert_output --partial "[   info] rm testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "_execute_: Good command - no output" {
    touch "testfile.txt"
    run _execute_ -q "rm testfile.txt"
    assert_success
    refute_output --partial "[   info] rm testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "_execute_ -s: Good command" {
    touch "testfile.txt"
    run _execute_ -s "rm testfile.txt"
    assert_success
    assert_output --partial "[success] rm testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "_execute_ -v: Good command" {
    touch "testfile.txt"
    run _execute_ -v "rm -v testfile.txt"

    assert_success
    assert_line --index 0 "removed 'testfile.txt'"
    assert_line --index 1 --partial "[   info] rm -v testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "_execute_ -n: Good command" {
    touch "testfile.txt"
    run _execute_ -n "rm -v testfile.txt"

    assert_success
    assert_line --index 0 --partial "[ notice] rm -v testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "_execute_ -ev: Good command" {
    touch "testfile.txt"
    run _execute_ -ve "rm -v testfile.txt"

    assert_success
    assert_line --index 0 "removed 'testfile.txt'"
    assert_line --index 1 --partial "rm -v testfile.txt"
    assert_file_not_exist "testfile.txt"
}

@test "_findBaseDir_" {
    run _findBaseDir_
    assert_success
    if [ -d /usr/local/Cellar/ ]; then
        assert_output --regexp "^/usr/local/Cellar/bats-core/[0-9][0-9]?\.[0-9][0-9]?\.[0-9][0-9]?"
    elif [ -d /opt/homebrew/Cellar ]; then
        assert_output --regexp "^/opt/homebrew/Cellar/bats-core/[0-9][0-9]?\.[0-9][0-9]?\.[0-9][0-9]?"
    fi
}

@test "_generateUUID_" {
    run _generateUUID_
    assert_success
    assert_output --regexp "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
}

@test "_spinner_: verbose" {
    verbose=true
    run _spinner_
    assert_success
    assert_output ""
}

@test "_spinner_: quiet" {
    quiet=true
    run _spinner_
    assert_success
    assert_output ""
}

@test "_progressBar_: verbose" {
    verbose=true
    run _progressBar_ 100
    assert_success
    assert_output ""
}

@test "_progressBar_: quiet" {
    quiet=true
    run _progressBar_ 100
    assert_success
    assert_output ""
}

@test "_seekConfirmation_: yes" {
    run _seekConfirmation_ 'test' <<<"y"
    assert_success
    assert_output --partial "[  input] test"
}

@test "_seekConfirmation_: no" {
    run _seekConfirmation_ 'test' <<<"n"
    assert_failure
    assert_output --partial "[  input] test"
}

@test "_seekConfirmation_: Force" {
    FORCE=true
    run _seekConfirmation_ "test"
    assert_success
    assert_output --partial "test"
}

@test "_seekConfirmation_: Quiet" {
    QUIET=true
    run _seekConfirmation_ 'test' <<<"y"
    assert_success
    refute_output --partial "test"
}
