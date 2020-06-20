#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::verify_arg_count().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Verifies the number of arguments received against expected values.
#
# Other functions in this library call this function to verify the number of
# arguments received. To prevent infinite loops, this function must not call
# any other function in this library, other than bfl::die.
#
# That is why we are essentially recreating:
# - bfl::verify_arg_count()
# - bfl::is_integer()
#
# @param int $actual_arg_count
#   Actual number of arguments received.
# @param int $expected_arg_count_min
#   Minimum number of arguments expected.
# @param int $expected_arg_count_max
#   Maximum number of arguments expected.
#
# @example
#   bfl::verify_arg_count "$#" 2 3
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::verify_arg_count() {
  # Verify argument count.
  if [[ "$#" -ne "3" ]]; then
    bfl::die "Invalid number of arguments. Expected 3, received $#."
  fi
  declare -r actual_arg_count="$1"
  declare -r expected_arg_count_min="$2"
  declare -r expected_arg_count_max="$3"
  declare -r regex="^[0-9]+$"
  declare error_msg

  # Make sure all of the arguments are integers.
  if ! [[ "${actual_arg_count}" =~ ${regex} ]] ; then
    bfl::die "\"${actual_arg_count}\" is not an integer."
  fi
  if ! [[ "${expected_arg_count_min}" =~ ${regex} ]] ; then
    bfl::die "\"${expected_arg_count_min}\" is not an integer."
  fi
  if ! [[ "${expected_arg_count_max}" =~ ${regex} ]] ; then
    bfl::die "\"${expected_arg_count_max}\" is not an integer."
  fi

  # Test.
  if [[ "${actual_arg_count}" -lt "${expected_arg_count_min}" || \
        "${actual_arg_count}" -gt "${expected_arg_count_max}" ]]; then
    if [[ "${expected_arg_count_min}" -eq "${expected_arg_count_max}" ]]; then
      error_msg="Invalid number of arguments. Expected "
      error_msg+="${expected_arg_count_min}, received ${actual_arg_count}."
    else
      error_msg="Invalid number of arguments. Expected between "
      error_msg+="${expected_arg_count_min} and ${expected_arg_count_max}, "
      error_msg+="received ${actual_arg_count}."
    fi
    printf "%b\\n" "${bfl_aes_red}Error. ${error_msg}${bfl_aes_reset}" 1>&2
    return 1
  fi
}
