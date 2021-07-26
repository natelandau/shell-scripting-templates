#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SCRIPT="${ROOTDIR}/scriptTemplate.sh"

if [ -f "${SCRIPT}" ]; then
    base="$(basename "${SCRIPT}")"
else
  echo "Can not find '${SCRIPT}" >&2
  exit 1
fi

setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  pushd "${TESTDIR}" &>/dev/null

}

teardown() {
  popd &>/dev/null
  temp_del "${TESTDIR}"
}


######## RUN TESTS ##########
@test "sanity" {
  run true
  assert_success
  assert [ "$output" = "" ]
}

@test "Fail - fail on bad args and create logfile" {
  run "${SCRIPT}" --logfile="${TESTDIR}/logs/log.txt" -K

  assert_failure
  assert_output --partial "[  fatal] invalid option: '-K'"
  assert_file_exist "${TESTDIR}/logs/log.txt"

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[  fatal\] .* invalid option: '-K'\. \(.*"
}

@test "success" {
  run "${SCRIPT}" --logfile="${TESTDIR}/logs/log.txt"
  assert_success
  assert_output --partial "[   info] Hello world"
  assert_file_not_exist "${TESTDIR}/logs/log.txt"
}

@test "success and INFO level log" {
  run "${SCRIPT}" --logfile="${TESTDIR}/logs/log.txt" --loglevel=INFO
  assert_success
  assert_output --partial "[   info] Hello world"

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[   info\].*Hello world"
}

@test "Usage (-h)" {
  run "${SCRIPT}" --logfile="${TESTDIR}/logs/log.txt" -h

  assert_success
  assert_line --partial --index 0 "$base [OPTION]... [FILE]..."
}

@test "Usage (--help)" {
  run "${SCRIPT}" --logfile="${TESTDIR}/logs/log.txt" --help

  assert_success
  assert_line --partial --index 0 "$base [OPTION]... [FILE]..."
}
