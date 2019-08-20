#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_empty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks if a string is empty ("") or null.
#
# @param string $str
#   The string to check.
#
# @example
#   bfl::is_empty "foo"
#------------------------------------------------------------------------------
bfl::is_empty() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare -r str="$1"

  # Check the string.
  [[ -z "${str}" ]] || return 1
}
