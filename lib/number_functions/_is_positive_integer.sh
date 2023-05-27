#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_positive_integer().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the argument is a positive integer.
#
# @param string $value_to_test
#   The value to be tested.
#
# @example
#   bfl::is_positive_integer "8675309"
#------------------------------------------------------------------------------
bfl::is_positive_integer() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r argument="$1"
  declare -r regex="^[1-9][0-9]*$"

  if ! [[ "${argument}" =~ ${regex} ]] ; then
    return 1
  fi
}
