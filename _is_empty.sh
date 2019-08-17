#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_empty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the argument is empty.
#
# @param string $argument
#   The value to be tested.
#
# @example
#   bfl::is_empty "foo"
#------------------------------------------------------------------------------
#
bfl::is_empty() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r argument="$1"

  if [[ -n "${argument}" ]] ; then
    return 1
  fi
}
