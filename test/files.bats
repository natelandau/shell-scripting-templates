#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

PATH="/usr/local/opt/gnu-tar/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/grep/libexec/gnubin:${PATH}"

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

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "bfl::get_file_name: with extension" {
  run bfl::get_file_name "./path/to/file/test.txt"
  assert_success
  assert_output "test.txt"
}

@test "bfl::get_file_name: without extension" {
  run bfl::get_file_name "path/to/file/test"
  assert_success
  assert_output "test"
}

@test "bfl::get_file_basename" {
  run bfl::get_file_basename "path/to/file/test.txt"
  assert_success
  assert_output "test"
}

@test "bfl::get_file_extension: simple extension" {
    run bfl::get_file_extension "path/to/file/test.txt"
  assert_success
  assert_output "txt"
}

@test "bfl::get_file_extension: no extension" {
    run bfl::get_file_extension "path/to/file/test"
  assert_failure
}

@test "bfl::get_file_extension: two level extension" {
  run bfl::get_file_extension "path/to/file/test.tar.bz2"
  assert_success
  assert_output "tar.bz2"
}

@test "bfl::get_canonical_path" {
    run bfl::get_canonical_path
    assert_success
    if [[ -d /usr/local/Cellar/ ]]; then
        assert_output --regexp "^/usr/local/Cellar/bats-core/[0-9]\.[0-9]\.[0-9]"
    elif [[ -d /opt/homebrew/Cellar ]]; then
        assert_output --regexp "^/opt/homebrew/Cellar/bats-core/[0-9]\.[0-9]\.[0-9]"
    fi
}
