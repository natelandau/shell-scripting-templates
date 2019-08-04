#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_empty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the supplied argument is an empty string.
#
# @param string $value_to_test
#   The value to be tested.
#------------------------------------------------------------------------------
#
bfl::is_empty() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r value_to_test="$1"

  if [[ -n "${value_to_test}" ]] ; then
    return 1
  fi
}
