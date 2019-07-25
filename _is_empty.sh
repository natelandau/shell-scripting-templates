#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::is_empty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the supplied argument is an empty string.
#
# @param string $value_to_test
#   The value to be tested.
#------------------------------------------------------------------------------
#
lib::is_empty() {
  lib::validate_arg_count "$#" 1 1 || exit 1

  declare -r value_to_test="$1"

  if [[ -n "${value_to_test}" ]] ; then
    return 1
  fi
}
