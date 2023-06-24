#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/arrays
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
  # Set arrays
  A=(one two three 1 2 3)
  B=(1 2 3 4 5 6)
  DUPES=(1 2 3 1 2 3)

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

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #
@test "Sanity..." {
  run true

  assert_success
  assert_output ""
  }

# ---------------------------------------------------------------------------- #
# bfl::array_contains_element                                                  #
# ---------------------------------------------------------------------------- #

@test "bfl::array_contains_element -> If ARRAY does contain ELEMENT, the function should return 0" {
  local -r T_ARRAY=( "abc" "xyz" )
  local -r ELEMENT="abc"

  run bfl::array_contains_element T_ARRAY[@] "${ELEMENT}"
  [ "${status}" -eq 0 ]
}

@test "bfl::array_contains_element -> If ARRAY does not contain ELEMENT, the function should return 1" {
  local -r T_ARRAY=( "abc" "xyz" )
  local -r ELEMENT="jkl"

  run bfl::array_contains_element T_ARRAY[@] "${ELEMENT}"
  [ "${status}" -eq 1 ]
}

@test "bfl::array_contains_element: success" {
  run bfl::array_contains_element "one" "${A[@]}"
  assert_success
  }

@test "bfl::array_contains_element: success and ignore case" {
  run bfl::array_contains_element -i "ONE" "${A[@]}"
  assert_success
  }

@test "bfl::array_contains_element: failure" {
  run bfl::array_contains_element ten "${A[@]}"
  assert_failure
  }

# ---------------------------------------------------------------------------- #
# bfl::array_intersects                                                        #
# ---------------------------------------------------------------------------- #

@test "bfl::array_intersects -> If ARRAY_1 has any intersections with ARRAY_2, the function should return 0" {
  local -r T_ARRAY_1=( "abc" "xyz" )
  local -r T_ARRAY_2=( "123" "456" "xyz" "789" )

  run bfl::array_intersects T_ARRAY_1[@] T_ARRAY_2[@]
  [ "${status}" -eq 0 ]
}

@test "bfl::array_intersects -> If ARRAY_1 has no intersections with ARRAY_2, the function should return 1" {
  local -r T_ARRAY_1=( "abc" "xyz" )
  local -r T_ARRAY_2=( "123" "456" "789" )

  run bfl::array_intersects T_ARRAY_1[@] T_ARRAY_2[@]
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------- #
# bfl::join_array                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::join_array -> If ARRAY does contain elements and DELIMITER is specified, the function should return 0 and the concatinated string" {
  local -r -a T_ARRAY=( "abc" "xyz" )
  local -r DELIMITER=" - "

  run bfl::join_array T_ARRAY[@] "${DELIMITER}"
  [ "${status}" -eq 0 ]
  [ "${output}" == "abc - xyz" ]
}

@test "bfl::join_array -> If ARRAY does contain elements and no DELIMITER is specified, the function should return 0 and the concatinated string with default delimiter" {
  local -r -a T_ARRAY=( "abc" "xyz" )

  run bfl::join_array T_ARRAY[@]
  [ "${status}" -eq 0 ]
  [ "${output}" == "abc,xyz" ]
}

@test "bfl::join_array -> If ARRAY does contain no element, the function should return 0 and an empty string" {
  local -r -a T_ARRAY=()

  run bfl::join_array T_ARRAY[@]
  [ "${status}" -eq 0 ]
  [ "${output}" == "" ]
}

@test "bfl::join_array -> If the function is called with no arguments, it should return 1 and an empty string" {
  run bfl::join_array
  [ "${status}" -eq 1 ]
  [ "${output}" == "" ]
}

@test "bfl::join_array: Join array comma" {
  run bfl::join_array , "${B[@]}"
  assert_success
  assert_output "1,2,3,4,5,6"
  }

@test "bfl::join_array: Join array space" {
  run bfl::join_array " " "${B[@]}"
  assert_success
  assert_output "1 2 3 4 5 6"
  }

@test "bfl::join_array: Join string complex" {
  run bfl::join_array , a "b c" d
  assert_success
  assert_output "a,b c,d"
  }

@test "bfl::join_array: join string simple" {
  run bfl::join_array / var usr tmp
  assert_success
  assert_output "var/usr/tmp"
  }

# ---------------------------------------------------------------------------- #
# bfl::get_diff_array                                                          #
# ---------------------------------------------------------------------------- #

@test "bfl::get_diff_array: Print elements not common to arrays" {
  run bfl::get_diff_array "A[@]" "B[@]"
  assert_success
  assert_line --index 0 "one"
  assert_line --index 1 "two"
  assert_line --index 2 "three"

  run bfl::get_diff_array "B[@]" "A[@]"
  assert_success
  assert_line --index 0 "4"
  assert_line --index 1 "5"
  assert_line --index 2 "6"
  }

@test "bfl::get_diff_array: Fail when no diff" {
  run bfl::get_diff_array "A[@]" "A[@]"
  assert_failure
  }

# ---------------------------------------------------------------------------- #
# bfl::get_random_array_element                                                #
# ---------------------------------------------------------------------------- #

@test "bfl::get_random_array_element" {
  run bfl::get_random_array_element "${A[@]}"
  assert_success
  assert_output --regexp '^one|two|three|1|2|3$'
  }

# ---------------------------------------------------------------------------- #
# bfl::dedupe_array                                                            #
# ---------------------------------------------------------------------------- #

@test "bfl::dedupe_array: remove duplicates" {
  run bfl::dedupe_array "${DUPES[@]}"
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
  }

# ---------------------------------------------------------------------------- #
# bfl::sort_array                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::sort_array" {
  unsorted_array=("c" "b" "c" "4" "1" "3" "a" "2" "d")
  run bfl::sort_array "${unsorted_array[@]}"
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
  assert_line --index 3 "4"
  assert_line --index 4 "a"
  assert_line --index 5 "b"
  assert_line --index 6 "c"
  assert_line --index 7 "c"
  assert_line --index 8 "d"
  }

@test "bfl::sort_array" {
  unsorted_array=("c" "b" "c" "4" "1" "3" "a" "2" "d")
  run bfl::sort_array --reverse "${unsorted_array[@]}"
  assert_success
  assert_line --index 0 "d"
  assert_line --index 1 "c"
  assert_line --index 2 "c"
  assert_line --index 3 "b"
  assert_line --index 4 "a"
  assert_line --index 5 "4"
  assert_line --index 6 "3"
  assert_line --index 7 "2"
  assert_line --index 8 "1"
  }

# ---------------------------------------------------------------------------- #
# bfl::merge_arrays                                                            #
# ---------------------------------------------------------------------------- #

@test "bfl::merge_arrays" {
  a1=(1 2 3)
  a2=(3 2 1)
  run bfl::merge_arrays "a1[@]" "a2[@]"
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
  assert_line --index 3 "3"
  assert_line --index 4 "2"
  assert_line --index 5 "1"
  }

# ---------------------------------------------------------------------------- #
# bfl::check_array_by_function_success_all_elements                            #
# ---------------------------------------------------------------------------- #

@test "bfl::check_array_by_function_success_all_elements" (
  test_func() {
      printf "print value: %s\n" "$1"
      return 0
    }
  array=(1 2 3 4 5)

  run bfl::check_array_by_function_success_all_elements "test_func" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_line --index 0 "print value: 1"
  assert_line --index 1 "print value: 2"
  assert_line --index 2 "print value: 3"
  assert_line --index 3 "print value: 4"
  assert_line --index 4 "print value: 5"
  )

@test "bfl::check_array_by_function_success_all_elements: success" {
  array=("a" "abcdef" "ppll" "xyz")

  run bfl::check_array_by_function_success_all_elements "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_success
  }

@test "bfl::check_array_by_function_success_all_elements: failure" {
  array=("a" "abcdef" "ppll99" "xyz")

  run bfl::check_array_by_function_success_all_elements "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_failure
  }

# ---------------------------------------------------------------------------- #
# bfl::check_array_by_function_result_return_1st_success_element               #
# ---------------------------------------------------------------------------- #

@test "bfl::check_array_by_function_result_return_1st_success_element: success" {
  array=("1" "234" "success" "45p9")

  run bfl::check_array_by_function_result_return_1st_success_element "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_output "success"
  }

@test "bfl::check_array_by_function_result_return_1st_success_element: failure" {
  array=("1" "2" "3" "4")

  run bfl::check_array_by_function_result_return_1st_success_element "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_failure
  }

# ---------------------------------------------------------------------------- #
# bfl::filter_array_by_function_success                                        #
# ---------------------------------------------------------------------------- #

@test "bfl::filter_array_by_function_success" {
  array=(1 2 3 a ab 5 cde 6)

  run bfl::filter_array_by_function_success "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_line --index 0 "a"
  assert_line --index 1 "ab"
  assert_line --index 2 "cde"
  }

# ---------------------------------------------------------------------------- #
# bfl::filter_array_by_function_fail                                           #
# ---------------------------------------------------------------------------- #

@test "bfl::filter_array_by_function_fail" {
  array=(1 2 3 a ab 5 cde 6)

  run bfl::filter_array_by_function_fail "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_success
  assert_line --index 0 "1"
  assert_line --index 1 "2"
  assert_line --index 2 "3"
  assert_line --index 3 "5"
  assert_line --index 4 "6"
  }

# ---------------------------------------------------------------------------- #
# bfl::_check_array_by_function_success_any_element                            #
# ---------------------------------------------------------------------------- #

@test "bfl::_check_array_by_function_success_any_element: success" {
  array=("1" "234" "success" "45p9")

  run bfl::_check_array_by_function_success_any_element "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_success
  }

@test "bfl::_check_array_by_function_success_any_element: failure" {
  array=("1" "2" "3" "4")

  run bfl::_check_array_by_function_success_any_element "bfl::is_alphabet" < <(printf "%s\n" "${array[@]}")
  assert_failure
  }
