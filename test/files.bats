#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-asser/load'

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

  pushd "${TESTDIR}" >&2

  ######## DEFAUL FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  QUIET=false
  LOGLEVEL=OFF
  VERBOSE=false
  FORCE=false
  DRYRUN=false
}

teardown() {
  popd >&2
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

  @test "_backupFile_: backup file" {
    touch "testfile"
    run _backupFile_ -d "testfile" "backup-files"

    assert_success
    assert [ -f "backup-files/testfile" ]
  }

  @test "_backupFile_: default destination & rename" {
    mkdir backup
    touch "testfile" "backup/testfile"
    run _backupFile_ -d "testfile"

    assert_success
    assert [ -f "backup/testfile-2" ]
  }

}














_testBackupFile_
