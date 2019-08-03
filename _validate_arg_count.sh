#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::validate_arg_count().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Validates the number of arguments received against expected values.
#
# Other functions in this library call this function to validate the number of
# arguments received. To prevent infinite loops, this function must not call
# any other function in this library, other than bfl::die.
#
# That is why we are essentially recreating:
# - bfl::validate_arg_count()
# - bfl::is_integer()
#
# @param integer $actual_arg_count
#   Actual number of arguments received.
# @param integer $expected_arg_count_min
#   Minimum number of arguments expected.
# @param integer $expected_arg_count_max
#   Maximum number of arguments expected.
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::validate_arg_count() {
  # Validate argument count.
  if [[ "$#" -ne "3" ]]; then
    bfl::die "Error: invalid number of arguments. Expected 3, received $#."
  fi
  declare -r actual_arg_count="$1"
  declare -r expected_arg_count_min="$2"
  declare -r expected_arg_count_max="$3"
  declare -r regex="^[0-9]+$"
  declare error_msg

  # Make sure all of the arguments are integers.
  if ! [[ "${actual_arg_count}" =~ ${regex} ]] ; then
    bfl::die "Error: \"${actual_arg_count}\" is not an integer."
  fi
  if ! [[ "${expected_arg_count_min}" =~ ${regex} ]] ; then
    bfl::die "Error: \"${expected_arg_count_min}\" is not an integer."
  fi
  if ! [[ "${expected_arg_count_max}" =~ ${regex} ]] ; then
    bfl::die "Error: \"${expected_arg_count_max}\" is not an integer."
  fi

  # Test.
  if [[ "${actual_arg_count}" -lt "${expected_arg_count_min}" || \
        "${actual_arg_count}" -gt "${expected_arg_count_max}" ]]; then
    error_msg="Error: invalid number of arguments. Expected between "
    error_msg+="${expected_arg_count_min} and ${expected_arg_count_max}, "
    error_msg+="received ${actual_arg_count}."
    echo -e "${red}${error_msg}${reset}" >&2
    return 1
  fi
}
