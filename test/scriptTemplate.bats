#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
s="${ROOTDIR}/scriptTemplate.sh"

if [ -f "${s}" ]; then
  base="$(basename "${s}")"
else
  printf "No executable '${s}' found.\n" >&2
  printf "Can not run tests.\n" >&2
  exit 1
fi


setup() {

  TESTDIR="$(temp_make)"
  curPath="${PWD}"

  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'

  s="$s --logfile=${TESTDIR}/logs/log.txt"  # Logs go to temp directory

  pushd "${TESTDIR}" >&2
}

teardown() {
  popd >&2
  temp_del "${TESTDIR}"
}


######## RUN TESTS ##########
@test "sanity" {
  run true
  assert_success
  assert [ "$output" = "" ]
}

@test "Fail - fail on bad args and create logfile" {
  run $s -K

  assert_failure
  assert_output --partial "[  fatal] invalid option: '-K'"
  assert_file_exist "${TESTDIR}/logs/log.txt"

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[  fatal\] .* invalid option: '-K'\. \(.*"
}

@test "success" {
  run $s
  assert_success
  assert_output --partial "[   info] Hello world"
  assert_file_not_exist "${TESTDIR}/logs/log.txt"
}

@test "success and INFO level log" {
  run $s --loglevel=INFO
  assert_success
  assert_output --partial "[   info] Hello world"

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[   info\].*Hello world"
}

@test "Usage (-h)" {
  run $s -h

  assert_success
  assert_line --partial --index 0 "$base [OPTION]... [FILE]..."
}

@test "Usage (--help)" {
  run $s --help

  assert_success
  assert_line --partial --index 0 "$base [OPTION]... [FILE]..."
}

@test "quiet (-q)" {
  run $s -q --loglevel=INFO
  assert_success
  assert_output ""

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[   info\].*Hello world"
}
