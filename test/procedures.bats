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

#  _setColors_ # Set Color Constants

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


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "bfl::make_tempdir" {
  VERBOSE=true
  run bfl::make_tempdir
  assert_success
  assert_output --regexp "\\\$TMP_DIR=/.*\.[0-9]+\.[0-9]+\.[0-9]+$"
}

@test "bfl::alert: success" {
  run success "testing"
  assert_output --regexp "\[success\] testing"
}

@test "bfl::alert: quiet" {
  BASH_INTERACTIVE=false
  run notice "testing"
  assert_success
  refute_output --partial "testing"
}

@test "bfl::alert: warning" {
  run warning "testing"
  assert_output --regexp "\[warning\] testing"
}

@test "bfl::alert: notice" {
  run notice "testing"
  assert_output --regexp "\[ notice\] testing"
}

@test "bfl::alert: notice: with LINE" {
  run notice "testing" "$LINENO"
  assert_output --regexp "\[ notice\] testing .*\(line: [0-9]{1,3}\)"
}

@test "bfl::alert: refute debug" {
  run debug "testing"
  refute_output --partial "[  debug] testing"
}

@test "bfl::alert: assert debug" {
  VERBOSE=true
  run debug "testing"
  assert_output --partial "[  debug] testing"
}

@test "bfl::alert: header" {
  run header "testing"
  assert_output --regexp "testing"
}

@test "bfl::alert: info" {
  run info "testing"
  assert_output --regexp "\[   info\] testing"
}

@test "bfl::alert: fatal: with LINE" {
  run fatal "testing" "$LINENO"
  assert_line --index 0 --regexp "\[  fatal\] testing .*\(line: [0-9]{1,3}\) \(.*\)"
}

@test "bfl::alert: error" {
  run error "testing"
  assert_output --regexp  "\[  error\] testing .*\(.*\)"
}

@test "bfl::alert: input" {
  run input "testing"
  assert_output --partial "[  input] testing"
}

@test "bfl::alert: logging FATAL" {
  LOGLEVEL=FATAL
  run error "testing error"
  run error "testing error 2"
  run warning "testing warning"
  run notice "testing notice"
  run info "testing info"
  run debug "testing debug"
  run fatal "testing fatal"
  set +o nounset

  assert_file_exist "${LOGFILE}"
  run cat "${LOGFILE}"
  assert_line --index 0 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  fatal\] \[.*\] testing fatal \("
  assert_line --index 1 ""
  assert_line --index 2 ""
  assert_line --index 3 ""
  assert_line --index 4 ""
  assert_line --index 5 ""
}

@test "bfl::alert: logging ERROR" {
  LOGLEVEL=ERROR
  run error "testing error"
  run error "testing error 2"
  run warning "testing warning"
  run notice "testing notice"
  run info "testing info"
  run debug "testing debug"
  set +o nounset

  assert_file_exist "${LOGFILE}"
  run cat "${LOGFILE}"
  assert_line --index 0 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error"
  assert_line --index 1 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error 2"
  assert_line --index 2 ""
  assert_line --index 3 ""
  assert_line --index 4 ""
  assert_line --index 5 ""
}

@test "bfl::alert: logging WARN" {
  LOGLEVEL=WARN
  run error "testing error"
  run error "testing error 2"
  run warning "testing warning"
  run notice "testing notice"
  run info "testing info"
  run debug "testing debug"
  set +o nounset
  assert_file_exist "${LOGFILE}"
  run cat "${LOGFILE}"
  assert_line --index 0 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error"
  assert_line --index 1 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error 2"
  assert_line --index 2 --regexp "[0-9]+:[0-9]+:[0-9]+ \[warning\] \[.*\] testing warning"
  assert_line --index 3 ""
  assert_line --index 4 ""
  assert_line --index 5 ""
}

@test "bfl::alert: logging INFO" {
  LOGLEVEL=INFO
  run error "testing error"
  run error "testing error 2"
  run warning "testing warning"
  run notice "testing notice"
  run info "testing info"
  run debug "testing debug"
  set +o nounset
  assert_file_exist "${LOGFILE}"
  run cat "${LOGFILE}"
  assert_line --index 0 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error"
  assert_line --index 1 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error 2"
  assert_line --index 2 --regexp "[0-9]+:[0-9]+:[0-9]+ \[warning\] \[.*\] testing warning"
  assert_line --index 3 --regexp "[0-9]+:[0-9]+:[0-9]+ \[ notice\] \[.*\] testing notice"
  assert_line --index 4 --regexp "[0-9]+:[0-9]+:[0-9]+ \[   info\] \[.*\] testing info"
  assert_line --index 5 ""
}

@test "bfl::alert: logging NOTICE" {
  LOGLEVEL=NOTICE
  run error "testing error"
  run error "testing error 2"
  run warning "testing warning"
  run notice "testing notice"
  run info "testing info"
  run debug "testing debug"
  set +o nounset
  assert_file_exist "${LOGFILE}"
  run cat "${LOGFILE}"
  assert_line --index 0 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error"
  assert_line --index 1 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error 2"
  assert_line --index 2 --regexp "[0-9]+:[0-9]+:[0-9]+ \[warning\] \[.*\] testing warning"
  assert_line --index 3 --regexp "[0-9]+:[0-9]+:[0-9]+ \[ notice\] \[.*\] testing notice"
  assert_line --index 4 ""
}

@test "bfl::alert: logging DEBUG" {
  LOGLEVEL=DEBUG
  run error "testing error"
  run error "testing error 2"
  run warning "testing warning"
  run notice "testing notice"
  run info "testing info"
  run debug "testing debug"
  set +o nounset
  assert_file_exist "${LOGFILE}"
  run cat "${LOGFILE}"
  assert_line --index 0 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error"
  assert_line --index 1 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  error\] \[.*\] testing error 2"
  assert_line --index 2 --regexp "[0-9]+:[0-9]+:[0-9]+ \[warning\] \[.*\] testing warning"
  assert_line --index 3 --regexp "[0-9]+:[0-9]+:[0-9]+ \[ notice\] \[.*\] testing notice"
  assert_line --index 4 --regexp "[0-9]+:[0-9]+:[0-9]+ \[   info\] \[.*\] testing info"
  assert_line --index 5 --regexp "[0-9]+:[0-9]+:[0-9]+ \[  debug\] \[.*\] testing debug"
}

@test "bfl::alert: logging OFF" {
  LOGLEVEL=OFF
  run error "testing error"
  run error "testing error 2"
  run warning "testing warning"
  run notice "testing notice"
  run info "testing info"
  run debug "testing debug"

  assert_file_not_exist "${LOGFILE}"
}

@test "bfl::function_exists: Success" {
  run bfl::function_exists "bfl::var_is_empty"
  assert_success
}

@test "bfl::function_exists: Failure" {
  run bfl::function_exists "_someUndefinedFunction_"
  assert_failure
}

@test "bfl::command_exists: true" {
  run bfl::command_exists "vi"
  assert_success
}

@test "bfl::command_exists: false" {
  run bfl::command_exists "someNonexistantBinary"
  assert_failure
}

@test "bfl::print_ansi" {
  testString="$(tput bold)$(tput setaf 9)This is bold red text$(tput sgr0).$(tput setaf 10)This is green text$(tput sgr0)"
  run bfl::print_ansi "${testString}"
  assert_success
  assert_output "\e[1m\e[91mThis is bold red text\e(B\e[m.\e[92mThis is green text\e(B\e[m"
}

@test "bfl::print_array_to_log: Array" {
  testArray=(1 2 3)
  VERBOSE=true
  run bfl::print_array_to_log "testArray"
  assert_success
  assert_line --index 1 "[  debug] 0 = 1"
  assert_line --index 2 "[  debug] 1 = 2"
  assert_line --index 3 "[  debug] 2 = 3"
}

@test "bfl::print_array_to_log: don't print unless verbose mode" {
  testArray=(1 2 3)
  VERBOSE=false
  run bfl::print_array_to_log "testArray"
  assert_success
  refute_output --partial "[  debug] 0 = 1"
  refute_output --partial "[  debug] 1 = 2"
  refute_output --partial "[  debug] 2 = 3"
}

@test "bfl::print_array_to_log: Associative array" {
  declare -A assoc_array
  VERBOSE=true
  assoc_array=([foo]=bar [baz]=foobar)
  run bfl::print_array_to_log "assoc_array"
  assert_success
  assert_line --index 1 "[  debug] foo = bar"
  assert_line --index 2 "[  debug] baz = foobar"
}

@test "bfl::print_array_to_log: print without verbose" {
  testArray=(1 2 3)
  VERBOSE=false
  run bfl::print_array_to_log -v "testArray"
  assert_success
  assert_output --partial "[   info] 0 = 1"
  assert_output --partial "[   info] 1 = 2"
  assert_output --partial "[   info] 2 = 3"
}

@test "bfl::wait_confirmation: yes" {
    run bfl::wait_confirmation 'test' <<<"y"
    assert_success
    assert_output --partial "[  input] test"
}

@test "bfl::wait_confirmation: no" {
    run bfl::wait_confirmation 'test' <<<"n"
    assert_failure
    assert_output --partial "[  input] test"
}

@test "bfl::wait_confirmation: Force" {
    FORCE=true
    run bfl::wait_confirmation "test"
    assert_success
    assert_output --partial "test"
}

@test "bfl::wait_confirmation: Quiet" {
    BASH_INTERACTIVE=false
    run bfl::wait_confirmation 'test' <<<"y"
    assert_success
    refute_output --partial "test"
}
