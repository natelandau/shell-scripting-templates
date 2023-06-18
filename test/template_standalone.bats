#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
s="${ROOTDIR}/template_standalone.sh"

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
  assert_output --partial "[  fatal] invalid option: -K"
  assert_file_exist "${TESTDIR}/logs/log.txt"

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[  fatal\] .* invalid option: -K \(.*"
}

@test "success" {
  run $s
  assert_success
  assert_output --partial "[   info] This is info text"
  assert_output --partial "[ notice] This is notice text"
  assert_output --partial "[ dryrun] This is dryrun text"
  assert_output --partial "[warning] This is warning text"
  assert_output --partial "[  error] This is error text"
  assert_output --partial "[success] This is success text"
  assert_output --partial "[  input] This is input text"

  assert_file_exist "${TESTDIR}/logs/log.txt"
  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[  error\] \[.*\] This is error text \( _mainScript_:${base}.* \)"
  assert_line --index 1 ""
}

@test "success and INFO level log" {
  run $s --loglevel=INFO
  assert_success
  assert_output --partial "[   info] This is info text"

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[   info\].*This is info text"
  assert_line --index 1 --regexp "\[ notice\].*This is notice text"
  assert_line --index 2 --regexp "\[warning\].*This is warning text"
  assert_line --index 3 --regexp "\[  error\].*This is error text"
  assert_line --index 4 --regexp "\[success\].*This is success text"
  assert_line --index 5 ""
}

@test "success and NOTICE level log" {
  run $s --loglevel=NOTICE
  assert_success
  assert_output --partial "[   info] This is info text"

  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[ notice\].*This is notice text"
  assert_line --index 1 --regexp "\[warning\].*This is warning text"
  assert_line --index 2 --regexp "\[  error\].*This is error text"
  assert_line --index 3 --regexp "\[success\].*This is success text"
  assert_line --index 4 ""
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
  run cat "${TESTDIR}/logs/log.txt"
  assert_line --index 0 --regexp "\[   info\].*This is info text"
  assert_line --index 1 --regexp "\[ notice\].*This is notice text"
  assert_line --index 2 --regexp "\[warning\].*This is warning text"
  assert_line --index 3 --regexp "\[  error\].*This is error text"
  assert_line --index 4 --regexp "\[success\].*This is success text"
  assert_line --index 5 ""
}
