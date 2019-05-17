#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::is_integer().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the supplied argument is an integer.
#
# @param string $value_to_test
#   The value to be tested.
#------------------------------------------------------------------------------
#
lib::is_integer() {
  lib::validate_arg_count "$#" 1 1 || return 1
  declare -r value_to_test="$1"
  declare -r regex="^[0-9]+$"

  if ! [[ "${value_to_test}" =~ ${regex} ]] ; then
    return 1
  fi
}
