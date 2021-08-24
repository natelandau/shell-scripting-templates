#!/usr/bin/env bats
#shellcheck disable

load 'test_helper/bats-support/load'
load 'test_helper/bats-file/load'
load 'test_helper/bats-assert/load'

######## SETUP TESTS ########
ROOTDIR="$(git rev-parse --show-toplevel)"
SOURCEFILE="${ROOTDIR}/utilities/dates.bash"
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
  ######## DEFAULT FLAGS ########
  LOGFILE="${TESTDIR}/logs/log.txt"
  QUIET=false
  LOGLEVEL=OFF
  VERBOSE=true
  FORCE=false
  DRYRUN=false
}

######## RUN TESTS ########
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}


@test "_monthToNumber_: 1" {
  run _monthToNumber_ "dec"
  assert_success
  assert_output "12"
}

@test "_monthToNumber_: 2" {
  run _monthToNumber_ "MARCH"
  assert_success
  assert_output "3"
}

@test "_monthToNumber_: Fail" {
  run _monthToNumber_ "somethingthatbreaks"
  assert_failure
}

@test "_numberToMonth_: 1" {
  run _numberToMonth_ "1"
  assert_success
  assert_output "January"
}

@test "_numberToMonth_: 2" {
  run _numberToMonth_ "02"
  assert_success
  assert_output "February"
}

@test "_numberToMonth_: Fail" {
  run _numberToMonth_ "13"
  assert_failure
}

@test "_parseDate_: YYYY MM DD 1" {
  run _parseDate_ "2019 06 01"
  assert_success
  assert_output --regexp "_parseDate_found: +2019 06 01"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +June"
  assert_output --regexp "_parseDate_month: +6"
}

@test "_parseDate_: YYYY MM DD 2" {
  run _parseDate_ "this is text 2019-06-01 and more text"
  assert_success
  assert_output --regexp "_parseDate_found: +2019-06-01"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +June"
  assert_output --regexp "_parseDate_month: +6"
  assert_output --regexp "_parseDate_day: +1"
}

@test "_parseDate_: YYYY MM DD fail 1" {
  run _parseDate_ "this is text 2019-99-01 and more text"
  assert_failure
}

@test "_parseDate_: YYYY MM DD fail 2" {
  run _parseDate_ "this is text 2019-06-99 and more text"
  assert_failure
}

@test "_parseDate_: Month DD, YYYY" {
  run _parseDate_ "this is text Oct 22, 2019 and more text"
  assert_success
  assert_output --regexp "_parseDate_found: +Oct 22, +2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +October"
  assert_output --regexp "_parseDate_month: +10"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: Month DD YYYY" {
  run _parseDate_ "Oct 22 2019"
  assert_success
  assert_output --regexp "_parseDate_found: +Oct 22 2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +October"
  assert_output --regexp "_parseDate_month: +10"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: Month DD, YY" {
  run _parseDate_ "this is text Oct 22, 19 and more text"
  assert_success
  assert_output --regexp "_parseDate_found: +Oct 22, 19"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +October"
  assert_output --regexp "_parseDate_month: +10"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: Month DD YY" {
  run _parseDate_ "Oct 22 19"
  assert_success
  assert_output --regexp "_parseDate_found: +Oct 22 19"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +October"
  assert_output --regexp "_parseDate_month: +10"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: DD Month, YYYY" {
  run _parseDate_ "22 June, 2019 and more text"
  assert_success
  assert_output --regexp "_parseDate_found: +22 June, 2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +June"
  assert_output --regexp "_parseDate_month: +6"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: DD Month YYYY" {
  run _parseDate_ "some text66-here-22 June 2019 and more text"
  assert_success
  assert_output --regexp "_parseDate_found: +22 June 2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +June"
  assert_output --regexp "_parseDate_month: +6"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: MM DD YYYY 1" {
  run _parseDate_ "this is text 12 22 2019 and more text"
  assert_success
  assert_output --regexp "_parseDate_found: +12 22 2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +December"
  assert_output --regexp "_parseDate_month: +12"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: MM DD YYYY 2" {
  run _parseDate_ "12 01 2019"
  assert_success
  assert_output --regexp "_parseDate_found: +12 01 2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +December"
  assert_output --regexp "_parseDate_month: +12"
  assert_output --regexp "_parseDate_day: +1"
}

@test "_parseDate_: MM DD YYYY 3" {
  run _parseDate_ "a-test-01-12-2019-is here"
  assert_success
  assert_output --regexp "_parseDate_found: +01-12-2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +12"
}

@test "_parseDate_: DD MM YYYY 1 " {
  run _parseDate_ "a-test-22/12/2019-is here"
  assert_success
  assert_output --regexp "_parseDate_found: +22/12/2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +December"
  assert_output --regexp "_parseDate_month: +12"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: DD MM YYYY 2 " {
  run _parseDate_ "a-test-32/12/2019-is here"
  assert_failure
}

@test "_parseDate_: DD MM YY" {
  run _parseDate_ "a-test-22-12-19-is here"
  assert_success
  assert_output --regexp "_parseDate_found: +22-12-19"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +December"
  assert_output --regexp "_parseDate_month: +12"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: MM DD YY 1 " {
  run _parseDate_ "a-test-12/22/19-is here"
  assert_success
  assert_output --regexp "_parseDate_found: +12/22/19"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +December"
  assert_output --regexp "_parseDate_month: +12"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: MM DD YY 2 " {
  run _parseDate_ "6 8 19"
  assert_success
  assert_output --regexp "_parseDate_found: +6 8 19"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +June"
  assert_output --regexp "_parseDate_month: +6"
  assert_output --regexp "_parseDate_day: +8"
}

@test "_parseDate_: MM DD YY 3 " {
  run _parseDate_ "6 8 191"
  assert_failure
}

@test "_parseDate_: MM DD YY 4 " {
  run _parseDate_ "6 34 19"
  assert_failure
}

@test "_parseDate_: MM DD YY 5 " {
  run _parseDate_ "34 12 19"
  assert_failure
}

@test "_parseDate_: Month, YYYY 1 " {
  run _parseDate_ "a-test-January, 2019-is here"
  assert_success
  assert_output --regexp "_parseDate_found: +January, 2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +1"
}

@test "_parseDate_: Month, YYYY 2 " {
  run _parseDate_ "mar-2019"
  assert_success
  assert_output --regexp "_parseDate_found: +mar-2019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +March"
  assert_output --regexp "_parseDate_month: +3"
  assert_output --regexp "_parseDate_day: +1"
}

@test "_parseDate_: YYYYMMDDHHMM 1" {
  run _parseDate_ "201901220228"
  assert_success
  assert_output --regexp "_parseDate_found: +201901220228"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +22"
  assert_output --regexp "_parseDate_hour: +2"
  assert_output --regexp "_parseDate_minute: +28"
}

@test "_parseDate_: YYYYMMDDHHMM 2" {
  run _parseDate_ "asdf 201901220228asdf "
  assert_success
  assert_output --regexp "_parseDate_found: +201901220228"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +22"
  assert_output --regexp "_parseDate_hour: +2"
  assert_output --regexp "_parseDate_minute: +28"
}

@test "_parseDate_: YYYYMMDDHH 1" {
  run _parseDate_ "asdf 2019012212asdf "
  assert_success
  assert_output --regexp "_parseDate_found: +2019012212"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +22"
  assert_output --regexp "_parseDate_hour: +12"
  assert_output --regexp "_parseDate_minute: +00"
}

@test "_parseDate_: YYYYMMDDHH 2" {
  run _parseDate_ "2019012212"
  assert_success
  assert_output --regexp "_parseDate_found: +2019012212"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +22"
  assert_output --regexp "_parseDate_hour: +12"
  assert_output --regexp "_parseDate_minute: +00"
}

@test "_parseDate_: MMDDYYYY 1" {
  run _parseDate_ "01222019"
  assert_success
  assert_output --regexp "_parseDate_found: +01222019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: MMDDYYYY 2" {
  run _parseDate_ "asdf 11222019 asdf"
  assert_success
  assert_output --regexp "_parseDate_found: +11222019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +November"
  assert_output --regexp "_parseDate_month: +11"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: DDMMYYYY 1" {
  run _parseDate_ "16012019"
  assert_success
  assert_output --regexp "_parseDate_found: +16012019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +January"
  assert_output --regexp "_parseDate_month: +1"
  assert_output --regexp "_parseDate_day: +16"
}

@test "_parseDate_: DDMMYYYY 2" {
  run _parseDate_ "asdf 16112019 asdf"
  assert_success
  assert_output --regexp "_parseDate_found: +16112019"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +November"
  assert_output --regexp "_parseDate_month: +11"
  assert_output --regexp "_parseDate_day: +16"
}

@test "_parseDate_: YYYYDDMM " {
  run _parseDate_ "20192210"
  assert_success
  assert_output --regexp "_parseDate_found: +20192210"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +October"
  assert_output --regexp "_parseDate_month: +10"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: YYYYMMDD 1" {
  run _parseDate_ "20191022"
  assert_success
  assert_output --regexp "_parseDate_found: +20191022"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +October"
  assert_output --regexp "_parseDate_month: +10"
  assert_output --regexp "_parseDate_day: +22"
}

@test "_parseDate_: YYYYMMDD 2" {
  run _parseDate_ "20191010"
  assert_success
  assert_output --regexp "_parseDate_found: +20191010"
  assert_output --regexp "_parseDate_year: +2019"
  assert_output --regexp "_parseDate_monthName: +October"
  assert_output --regexp "_parseDate_month: +10"
  assert_output --regexp "_parseDate_day: +10"
}

@test "_parseDate_: YYYYMMDD fail" {
  run _parseDate_ "20199910"
  assert_failure
}

@test "_parseDate_: fail - no input" {
  run _parseDate_
  assert_failure
}

@test "_parseDate_: fail - no date" {
  run _parseDate_ "a string with some numbers 1234567"
  assert_failure
}

@test "_formatDate_: default" {
  run _formatDate_ "jan 21, 2019"
  assert_success
  assert_output "2019-01-21"
}

@test "_formatDate_: custom format " {
  run _formatDate_ "2019-12-27" "+%m %d, %Y"
  assert_success
  assert_output "12 27, 2019"
}

@test "_formatDate_: fail - no input " {
  run _formatDate_
  assert_failure
}
