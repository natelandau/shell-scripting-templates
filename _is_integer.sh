#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_integer().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the argument is an integer.
#
# @param string $value_to_test
#   The value to be tested.
#
# @example
#   bfl::is_integer "8675309"
#------------------------------------------------------------------------------
#
bfl::is_integer() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r argument="$1"
  declare -r regex="^-{0,1}[0-9]+$"

  if ! [[ "${argument}" =~ ${regex} ]] ; then
    return 1
  fi
}
