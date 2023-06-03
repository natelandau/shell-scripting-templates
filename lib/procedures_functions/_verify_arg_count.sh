#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
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
  [[ "$#" -ne "3" ]] && bfl::die "Invalid number of arguments. Expected 3, received $#."

  # Make sure all of the arguments are integers.
  local -r regex="^[0-9]+$"
  ! [[ "$1" =~ $regex ]] && bfl::die "\"$1\" is not an integer."
  ! [[ "$2" =~ $regex ]] && bfl::die "\"$2\" is not an integer."
  ! [[ "$3" =~ $regex ]] && bfl::die "\"$3\" is not an integer."

  # Test.
  declare error_msg

  if [[ "$1" -lt "$2" || "$1" -gt "$3" ]]; then
      error_msg="Invalid number of arguments. Expected "
      [[ "$2" -eq "$3" ]] && error_msg+="$2, received $1." || error_msg+="between $2 and $3, received $1."

      printf "%b\\n" "${bfl_aes_red}Error. $error_msg${bfl_aes_reset}" 1>&2
      return 1
  fi
  }
