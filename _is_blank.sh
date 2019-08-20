#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_blank().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks if a string is whitespace, empty (""), or null.
#
# Backslash escape sequences are interpreted prior to evaluation. Whitespace
# characters include space, horizontal tab (\t), new line (\n), vertical
# tab (\v), form feed (\f), and carriage return (\r).
#
# @param string $str
#   The string to check.
#
# @example
#   bfl::is_blank "foo"
#------------------------------------------------------------------------------
bfl::is_blank() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare -r str="$1"

  # Check the string.
  [[ "$(printf "%b" "${str}")" =~ ^[[:space:]]*$ ]] || return 1
}
