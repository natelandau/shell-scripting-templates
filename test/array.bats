#!/usr/bin/env bats

# Unittests for the functions in Array.sh
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #

source "${BATS_TEST_DIRNAME}/../lib/Array.sh"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# Array::contains_element                                                      #
# ---------------------------------------------------------------------------- #

@test "Array::contains_element -> If ARRAY does contain ELEMENT, the function should return 0" {
  local -r T_ARRAY=( "abc" "xyz" )
  local -r ELEMENT="abc"

  run Array::contains_element T_ARRAY[@] "${ELEMENT}"
  [ "${status}" -eq 0 ]
}

@test "Array::contains_element -> If ARRAY does not contain ELEMENT, the function should return 1" {
  local -r T_ARRAY=( "abc" "xyz" )
  local -r ELEMENT="jkl"

  run Array::contains_element T_ARRAY[@] "${ELEMENT}"
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# Array::intersects_array                                                      #
# ---------------------------------------------------------------------------- #

@test "Array::intersects -> If ARRAY_1 has any intersections with ARRAY_2, the function should return 0" {
  local -r T_ARRAY_1=( "abc" "xyz" )
  local -r T_ARRAY_2=( "123" "456" "xyz" "789" )

  run Array::intersects T_ARRAY_1[@] T_ARRAY_2[@]
  [ "${status}" -eq 0 ]
}

@test "Array::intersects -> If ARRAY_1 has no intersections with ARRAY_2, the function should return 1" {
  local -r T_ARRAY_1=( "abc" "xyz" )
  local -r T_ARRAY_2=( "123" "456" "789" )

  run Array::intersects T_ARRAY_1[@] T_ARRAY_2[@]
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# Array::join                                                                  #
# ---------------------------------------------------------------------------- #

@test "Array::join -> If ARRAY does contain elements and DELIMITER is specified, the function should return 0 and the concatinated string" {
  local -r -a T_ARRAY=( "abc" "xyz" )
  local -r DELIMITER=" - "

  run Array::join T_ARRAY[@] "${DELIMITER}"
  [ "${status}" -eq 0 ]
  [ "${output}" == "abc - xyz" ]
}

@test "Array::join -> If ARRAY does contain elements and no DELIMITER is specified, the function should return 0 and the concatinated string with default delimiter" {
  local -r -a T_ARRAY=( "abc" "xyz" )

  run Array::join T_ARRAY[@]
  [ "${status}" -eq 0 ]
  [ "${output}" == "abc,xyz" ]
}

@test "Array::join -> If ARRAY does contain no element, the function should return 0 and an empty string" {
  local -r -a T_ARRAY=()

  run Array::join T_ARRAY[@]
  [ "${status}" -eq 0 ]
  [ "${output}" == "" ]
}

@test "Array::join -> If the function is called with no arguments, it should return 1 and an empty string" {
  run Array::join
  [ "${status}" -eq 1 ]
  [ "${output}" == "" ]
}
