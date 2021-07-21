#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/files.bash"
BASEHELPERS="${ROOTDIR}/utilities/baseHelpers.bash"
ALERTS="${ROOTDIR}/utilities/alerts.bash"

if test -f "${SOURCEFILE}" >&2; then
  source "${SOURCEFILE}"
else
  echo "Sourcefile not found: ${SOURCEFILE}" >&2
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

  pushd "${TESTDIR}" &>/dev/null

  ######## DEFAUL FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  QUIET=false
  LOGLEVEL=OFF
  VERBOSE=false
  FORCE=false
  DRYRUN=false
}

teardown() {
  popd &>/dev/null
  temp_del "${TESTDIR}"
}

######## FIXTURES ########
YAML1="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml"
YAML1parse="${BATS_TEST_DIRNAME}/fixtures/yaml1.yaml.txt"
YAML2="${BATS_TEST_DIRNAME}/fixtures/yaml2.yaml"
JSON="${BATS_TEST_DIRNAME}/fixtures/json.json"
unencrypted="${BATS_TEST_DIRNAME}/fixtures/test.md"
encrypted="${BATS_TEST_DIRNAME}/fixtures/test.md.enc"

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

_testBackupFile_() {

  @test "_backupFile_: no source" {
    run _backupFile_ "testfile"

    assert_failure
  }

  @test "_backupFile_: simple backup" {
    touch "testfile"
    run _backupFile_ "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_exist "testfile"
  }

  @test "_backupFile_: backup and unique name" {
    touch "testfile"
    touch "testfile.bak"
    run _backupFile_ "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_exist "testfile"
    assert_file_exist "testfile.bak.1"
  }

  @test "_backupFile_: move" {
    touch "testfile"
    run _backupFile_ -m "testfile"

    assert_success
    assert_file_exist "testfile.bak"
    assert_file_not_exist "testfile"
  }

  @test "_backupFile_: directory" {
    touch "testfile"
    run _backupFile_ -d "testfile"

    assert_success
    assert_file_exist "backup/testfile"
    assert_file_exist "testfile"
  }

  @test "_backupFile_: move to directory w/ custom name" {
    touch "testfile"
    run _backupFile_ -dm "testfile" "dir"

    assert_success
    assert_file_exist "dir/testfile"
    assert_file_not_exist "testfile"
  }

}

_testListFiles_() {
  @test "_listFiles_: glob" {
    touch yestest{1,2,3}.txt
    touch notest{1,2,3}.txt
    run _listFiles_ g "yestest*.txt" "${TESTDIR}"

    assert_success
    assert_output --partial "yestest1.txt"
    refute_output --partial "notest1.txt"
  }

  @test "_listFiles_: regex" {
    touch yestest{1,2,3}.txt
    touch notest{1,2,3}.txt
    run _listFiles_ regex ".*notest[0-9]\.txt" "${TESTDIR}"

    assert_success
    refute_output --partial "yestest1.txt"
    assert_output --partial "notest1.txt"
  }
}













_testBackupFile_
_testListFiles_
