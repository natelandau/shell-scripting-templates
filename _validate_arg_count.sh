#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::validate_arg_count().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Validates the number of arguments received against expected values.
#
# Other functions in this library call this function to validate the number of
# arguments received. To prevent infinite loops, this function must not call
# any other function in this library.
#
# That is why we are essentially recreating:
# - lib::validate_arg_count()
# - lib::is_integer()
# - lib::err()
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
lib::validate_arg_count() {
  # Validate argument count.
  if [[ "$#" -ne "3" ]]; then
    message="Error: invalid number of arguments (expected 3, received $#)."
    echo -e "${red}${message} ${yellow}[${FUNCNAME[0]}]${reset}" >&2
    return 1
  fi
  declare -r actual_arg_count="$1"
  declare -r expected_arg_count_min="$2"
  declare -r expected_arg_count_max="$3"
  declare message
  declare -r regex="^[0-9]+$"

  # Make sure all of the arguments are integers.
  if ! [[ "${actual_arg_count}" =~ ${regex} ]] ; then
    message="Error: \"${actual_arg_count}\" is not an integer."
    echo -e "${red}${message} ${yellow}[${FUNCNAME[0]}]${reset}" >&2
    return 1
  fi
  if ! [[ "${expected_arg_count_min}" =~ ${regex} ]] ; then
    message="Error: \"${expected_arg_count_min}\" is not an integer."
    echo -e "${red}${message} ${yellow}[${FUNCNAME[0]}]${reset}" >&2
    return 1
  fi
    if ! [[ "${expected_arg_count_max}" =~ ${regex} ]] ; then
    message="Error: \"${expected_arg_count_max}\" is not an integer."
    echo -e "${red}${message} ${yellow}[${FUNCNAME[0]}]${reset}" >&2
    return 1
  fi

  # Test.
  if [[ "${actual_arg_count}" -lt "${expected_arg_count_min}" || "${actual_arg_count}" -gt "${expected_arg_count_max}" ]]; then
    message="Error: invalid number of arguments (expected between ${expected_arg_count_min} and ${expected_arg_count_max}, received ${actual_arg_count})."
    echo -e "${red}${message}${reset}" >&2
    return 1
  fi
}
