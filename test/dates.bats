#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/compile
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #
[[ ${_GUARD_BFL_autoload} -eq 1 ]] || { . ${HOME}/getConsts; . "$BASH_FUNCTION_LIBRARY"; }


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #
load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

#ROOTDIR="$(git rev-parse --show-toplevel)"

# **************************************************************************** #
# Setup tests                                                                  #
# **************************************************************************** #
setup() {
  TESTDIR="$(temp_make)"
  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  BASH_INTERACTIVE=true
  LOGLEVEL=OFF
  VERBOSE=true
  FORCE=false
  DRYRUN=false
  }

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
  }

# ---------------------------------------------------------------------------- #
# bfl::get_unix_timestamp                                                      #
# ---------------------------------------------------------------------------- #
@test "bfl::get_unix_timestamp" {
  run bfl::get_unix_timestamp

  assert_success
  assert_output --regexp "^[0-9]+$"
  }

# ---------------------------------------------------------------------------- #
# bfl::date_string_to_unix_timestamp                                           #
# ---------------------------------------------------------------------------- #
@test "bfl::date_string_to_unix_timestamp" {
  run bfl::date_string_to_unix_timestamp "2020-07-07 18:38"
  assert_success
  assert_output "1594161480"
  }

# ---------------------------------------------------------------------------- #
# bfl::unix_timestamp_to_date_string                                           #
# ---------------------------------------------------------------------------- #
@test "bfl::unix_timestamp_to_date_string: Default Format" {
  run bfl::unix_timestamp_to_date_string "1591554426"
  assert_success
  assert_output "2020-06-07 14:27:06"
  }

@test "bfl::unix_timestamp_to_date_string: Custom format" {
  run bfl::unix_timestamp_to_date_string "1591554426" "%Y-%m-%d"
  assert_success
  assert_output "2020-06-07"
  }

# ---------------------------------------------------------------------------- #
# bfl::get_month_number_by_caption                                             #
# ---------------------------------------------------------------------------- #
@test "bfl::get_month_number_by_caption: 1" {
  run bfl::get_month_number_by_caption "dec"
  assert_success
  assert_output "12"
  }

@test "bfl::get_month_number_by_caption: 2" {
  run bfl::get_month_number_by_caption "MARCH"
  assert_success
  assert_output "3"
  }

@test "bfl::get_month_number_by_caption: Fail" {
  run bfl::get_month_number_by_caption "somethingthatbreaks"
  assert_failure
  }

# ---------------------------------------------------------------------------- #
# bfl::get_month_caption_by_number                                             #
# ---------------------------------------------------------------------------- #
@test "bfl::get_month_caption_by_number: 1" {
  run bfl::get_month_caption_by_number "1"
  assert_success
  assert_output "January"
  }

@test "bfl::get_month_caption_by_number: 2" {
  run bfl::get_month_caption_by_number "02"
  assert_success
  assert_output "February"
  }

@test "bfl::get_month_caption_by_number: Fail" {
  run bfl::get_month_caption_by_number "13"
  assert_failure
  }

# ---------------------------------------------------------------------------- #
# bfl::parse_date                                                              #
# ---------------------------------------------------------------------------- #
@test "bfl::parse_date: YYYY MM DD 1" {
  run bfl::parse_date "2019 06 01"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +2019 06 01"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +June"
  assert_output --regexp "PARSE_DATE_MONTH: +6"
  }

@test "bfl::parse_date: YYYY MM DD 2" {
  run bfl::parse_date "this is text 2019-06-01 and more text"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +2019-06-01"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +June"
  assert_output --regexp "PARSE_DATE_MONTH: +6"
  assert_output --regexp "PARSE_DATE_DAY: +1"
  }

@test "bfl::parse_date: YYYY MM DD fail 1" {
  run bfl::parse_date "this is text 2019-99-01 and more text"
  assert_failure
  }

@test "bfl::parse_date: YYYY MM DD fail 2" {
  run bfl::parse_date "this is text 2019-06-99 and more text"
  assert_failure
  }

@test "bfl::parse_date: Month DD, YYYY" {
  run bfl::parse_date "this is text Oct 22, 2019 and more text"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +Oct 22, +2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +October"
  assert_output --regexp "PARSE_DATE_MONTH: +10"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: Month DD YYYY" {
  run bfl::parse_date "Oct 22 2019"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +Oct 22 2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +October"
  assert_output --regexp "PARSE_DATE_MONTH: +10"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: Month DD, YY" {
  run bfl::parse_date "this is text Oct 22, 19 and more text"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +Oct 22, 19"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +October"
  assert_output --regexp "PARSE_DATE_MONTH: +10"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: Month DD YY" {
  run bfl::parse_date "Oct 22 19"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +Oct 22 19"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +October"
  assert_output --regexp "PARSE_DATE_MONTH: +10"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: DD Month, YYYY" {
  run bfl::parse_date "22 June, 2019 and more text"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +22 June, 2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +June"
  assert_output --regexp "PARSE_DATE_MONTH: +6"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: DD Month YYYY" {
  run bfl::parse_date "some text66-here-22 June 2019 and more text"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +22 June 2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +June"
  assert_output --regexp "PARSE_DATE_MONTH: +6"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: MM DD YYYY 1" {
  run bfl::parse_date "this is text 12 22 2019 and more text"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +12 22 2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +December"
  assert_output --regexp "PARSE_DATE_MONTH: +12"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: MM DD YYYY 2" {
  run bfl::parse_date "12 01 2019"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +12 01 2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +December"
  assert_output --regexp "PARSE_DATE_MONTH: +12"
  assert_output --regexp "PARSE_DATE_DAY: +1"
  }

@test "bfl::parse_date: MM DD YYYY 3" {
  run bfl::parse_date "a-test-01-12-2019-is here"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +01-12-2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +12"
  }

@test "bfl::parse_date: DD MM YYYY 1 " {
  run bfl::parse_date "a-test-22/12/2019-is here"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +22/12/2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +December"
  assert_output --regexp "PARSE_DATE_MONTH: +12"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: DD MM YYYY 2 " {
  run bfl::parse_date "a-test-32/12/2019-is here"
  assert_failure
  }

@test "bfl::parse_date: DD MM YY" {
  run bfl::parse_date "a-test-22-12-19-is here"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +22-12-19"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +December"
  assert_output --regexp "PARSE_DATE_MONTH: +12"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: MM DD YY 1 " {
  run bfl::parse_date "a-test-12/22/19-is here"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +12/22/19"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +December"
  assert_output --regexp "PARSE_DATE_MONTH: +12"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: MM DD YY 2 " {
  run bfl::parse_date "6 8 19"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +6 8 19"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +June"
  assert_output --regexp "PARSE_DATE_MONTH: +6"
  assert_output --regexp "PARSE_DATE_DAY: +8"
  }

@test "bfl::parse_date: MM DD YY 3 " {
  run bfl::parse_date "6 8 191"
  assert_failure
  }

@test "bfl::parse_date: MM DD YY 4 " {
  run bfl::parse_date "6 34 19"
  assert_failure
  }

@test "bfl::parse_date: MM DD YY 5 " {
  run bfl::parse_date "34 12 19"
  assert_failure
  }

@test "bfl::parse_date: Month, YYYY 1 " {
  run bfl::parse_date "a-test-January, 2019-is here"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +January, 2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +1"
  }

@test "bfl::parse_date: Month, YYYY 2 " {
  run bfl::parse_date "mar-2019"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +mar-2019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +March"
  assert_output --regexp "PARSE_DATE_MONTH: +3"
  assert_output --regexp "PARSE_DATE_DAY: +1"
  }

@test "bfl::parse_date: YYYYMMDDHHMM 1" {
  run bfl::parse_date "201901220228"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +201901220228"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  assert_output --regexp "PARSE_DATE_HOUR: +2"
  assert_output --regexp "PARSE_DATE_MINUTE: +28"
  }

@test "bfl::parse_date: YYYYMMDDHHMM 2" {
  run bfl::parse_date "asdf 201901220228asdf "
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +201901220228"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  assert_output --regexp "PARSE_DATE_HOUR: +2"
  assert_output --regexp "PARSE_DATE_MINUTE: +28"
  }

@test "bfl::parse_date: YYYYMMDDHH 1" {
  run bfl::parse_date "asdf 2019012212asdf "
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +2019012212"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  assert_output --regexp "PARSE_DATE_HOUR: +12"
  assert_output --regexp "PARSE_DATE_MINUTE: +00"
  }

@test "bfl::parse_date: YYYYMMDDHH 2" {
  run bfl::parse_date "2019012212"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +2019012212"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  assert_output --regexp "PARSE_DATE_HOUR: +12"
  assert_output --regexp "PARSE_DATE_MINUTE: +00"
  }

@test "bfl::parse_date: MMDDYYYY 1" {
  run bfl::parse_date "01222019"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +01222019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: MMDDYYYY 2" {
  run bfl::parse_date "asdf 11222019 asdf"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +11222019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +November"
  assert_output --regexp "PARSE_DATE_MONTH: +11"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: DDMMYYYY 1" {
  run bfl::parse_date "16012019"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +16012019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +January"
  assert_output --regexp "PARSE_DATE_MONTH: +1"
  assert_output --regexp "PARSE_DATE_DAY: +16"
  }

@test "bfl::parse_date: DDMMYYYY 2" {
  run bfl::parse_date "asdf 16112019 asdf"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +16112019"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +November"
  assert_output --regexp "PARSE_DATE_MONTH: +11"
  assert_output --regexp "PARSE_DATE_DAY: +16"
  }

@test "bfl::parse_date: YYYYDDMM " {
  run bfl::parse_date "20192210"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +20192210"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +October"
  assert_output --regexp "PARSE_DATE_MONTH: +10"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: YYYYMMDD 1" {
  run bfl::parse_date "20191022"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +20191022"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +October"
  assert_output --regexp "PARSE_DATE_MONTH: +10"
  assert_output --regexp "PARSE_DATE_DAY: +22"
  }

@test "bfl::parse_date: YYYYMMDD 2" {
  run bfl::parse_date "20191010"
  assert_success
  assert_output --regexp "PARSE_DATE_FOUND: +20191010"
  assert_output --regexp "PARSE_DATE_YEAR: +2019"
  assert_output --regexp "PARSE_DATE_MONTH_NAME: +October"
  assert_output --regexp "PARSE_DATE_MONTH: +10"
  assert_output --regexp "PARSE_DATE_DAY: +10"
  }

@test "bfl::parse_date: YYYYMMDD fail" {
  run bfl::parse_date "20199910"
  assert_failure
  }

@test "bfl::parse_date: fail - no input" {
  run bfl::parse_date
  assert_failure
  }

@test "bfl::parse_date: fail - no date" {
  run bfl::parse_date "a string with some numbers 1234567"
  assert_failure
  }

# ---------------------------------------------------------------------------- #
# bfl::format_date                                                             #
# ---------------------------------------------------------------------------- #
@test "bfl::format_date: default" {
  run bfl::format_date "jan 21, 2019"
  assert_success
  assert_output "2019-01-21"
  }

@test "bfl::format_date: custom format " {
  run bfl::format_date "2019-12-27" "+%m %d, %Y"
  assert_success
  assert_output "12 27, 2019"
  }

# ---------------------------------------------------------------------------- #
# bfl::seconds_to_date_string                                                  #
# ---------------------------------------------------------------------------- #
@test "bfl::seconds_to_date_string: Seconds to human readable" {
  run bfl::seconds_to_date_string "9255"
  assert_success
  assert_output "02:34:15"
  }

# ---------------------------------------------------------------------------- #
# bfl::date_string_to_seconds                                                  #
# ---------------------------------------------------------------------------- #
@test "bfl::date_string_to_seconds: HH MM SS to Seconds" {
  run bfl::date_string_to_seconds 12 3 33
  assert_success
  assert_output "43413"
  }

# ---------------------------------------------------------------------------- #
# bfl::sleep                                                                   #
# ---------------------------------------------------------------------------- #
@test "bfl::sleep: custom message, default wait" {
  run bfl::sleep 10 0 "something"
  assert_line --index 0 --partial "something 10"
  assert_line --index 9 --partial "something 1"
  }

@test "bfl::sleep: default message, custom wait" {
  run bfl::sleep 5 0
  assert_line --index 0 --partial "... 5"
  assert_line --index 4 --partial "... 1"
  }

@test "bfl::sleep: all defaults" {
  run bfl::sleep
  assert_line --index 0 --partial "... 10"
  assert_line --index 9 --partial "... 1"
  }
