#!/usr/bin/env bash

#------------------------------------------------------------------------------
#
# @file
# Defines function: bfl::is_number().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the argument is a float number.
#
# @param string $value_to_test
#   The value to be tested.
#
# @example
#   bfl::is_number "0.8675309"
#------------------------------------------------------------------------------
#
bfl::is_number() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r argument="$1"
  ! [[ "${argument}" =~ ^[-+]?[0-9]*[.,]?[0-9]+$ ]] && return 1
}
