#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

PATH="/usr/local/opt/gnu-tar/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/grep/libexec/gnubin:${PATH}"

#ROOTDIR="$(git rev-parse --show-toplevel)"
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY"; }

######## SETUP TESTS ########
setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" &>/dev/null

  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  BASH_INTERACTIVE=true
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

######## FIXTURES ########
TEXT="${BATS_TEST_DIRNAME}/fixtures/text.txt"
YAML1="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml"
YAML1parse="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml.txt"
unencrypted="${BATS_TEST_DIRNAME}/fixtures/test.md"
encrypted="${BATS_TEST_DIRNAME}/fixtures/test.md.enc"

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

_testBackupFile_() {

  @test "bfl::backup_file: no source" {
    run bfl::backup_file "testfile"

    assert_failure
  }

  @test "bfl::backup_file: simple backup" {
    touch "testfile"
    run bfl::backup_file "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_exist "testfile"
  }

  @test "bfl::backup_file: backup and unique name" {
    touch "testfile"
    touch "testfile.bak"
    run bfl::backup_file "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_exist "testfile"
    assert_file_exist "testfile.bak.1"
  }

  @test "bfl::backup_file: move" {
    touch "testfile"
    run bfl::backup_file -m "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_not_exist "testfile"
  }

  @test "bfl::backup_file: directory" {
    touch "testfile"
    run bfl::backup_file -d "testfile"

    assert_success
    assert_file_exist "backup/testfile"
    assert_file_exist "testfile"
  }

  @test "bfl::backup_file: move to directory w/ custom name" {
    touch "testfile"
    run bfl::backup_file -dm "testfile" "dir"

    assert_success
    assert_file_exist "dir/testfile"
    assert_file_not_exist "testfile"
  }

}

_testMakeSymlink_() {

  @test "bfl::make_symlink: Fail with no source fire" {
    run bfl::make_symlink "sourceFile" "destFile"

    assert_failure
  }

  @test "bfl::make_symlink: fail with no specified destination" {
    touch "test.txt"
    run bfl::make_symlink "test.txt"

    assert_failure
  }

  @test "bfl::make_symlink: make link" {
    touch "test.txt"
    touch "test2.txt"
    run bfl::make_symlink "${TESTDIR}/test.txt" "${TESTDIR}/test2.txt"

    assert_success
    assert_output --regexp "\[   info\] symlink /.*/test\.txt → /.*/test2\.txt"
    assert_link_exist "test2.txt"
    assert_file_exist "test2.txt.bak"
  }

  @test "bfl::make_symlink: Ignore already existing links" {
    touch "test.txt"
    ln -s "$(realpath test.txt)" "${TESTDIR}/test2.txt"
    run bfl::make_symlink "$(realpath test.txt)" "${TESTDIR}/test2.txt"

    assert_success
    assert_link_exist "test2.txt"
    assert_output --regexp "\[   info\] Symlink already exists: /.*/test\.txt → /.*/test2\.txt"
  }

  @test "bfl::make_symlink: Ignore already existing links - quiet" {
    touch "test.txt"
    ln -s "$(realpath test.txt)" "${TESTDIR}/test2.txt"
    run bfl::make_symlink -c "$(realpath test.txt)" "${TESTDIR}/test2.txt"

    assert_success
    assert_link_exist "test2.txt"
    assert_output ""
  }

  @test "bfl::make_symlink: Ignore already existing links - dryrun" {
    DRYRUN=true
    touch "test.txt"
    ln -s "$(realpath test.txt)" "${TESTDIR}/test2.txt"
    run bfl::make_symlink "$(realpath test.txt)" "${TESTDIR}/test2.txt"

    assert_success
    assert_link_exist "test2.txt"
    assert_output --regexp "\[ dryrun\] Symlink already exists: /.*/test\.txt → /.*/test2\.txt"
  }

  @test "bfl::make_symlink: Don't make backup" {
    touch "test.txt"
    touch "test2.txt"
    run bfl::make_symlink -n "${TESTDIR}/test.txt" "${TESTDIR}/test2.txt"

    assert_success
    assert_output --regexp "\[   info\] symlink /.*/test\.txt → /.*/test2\.txt"
    assert_link_exist "test2.txt"
    assert_file_not_exist "test2.txt.bak"
  }

}

_testBackupFile_
_testMakeSymlink_
