#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::repeat().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Repeats a string.
#
# @param string $str
#   The string to be repeated.
#
# @param int $multiplier
#   Number of times the string will be repeated.
#
# @return string $str_repeated
#   The repeated string.
#
# @example
#   bfl::repeat "=" "10"
#------------------------------------------------------------------------------
bfl::repeat() {
  bfl::verify_arg_count "$#" 2 2 || exit 1  # Verify argument count.

  # Verify argument values.
  bfl::is_positive_integer "$2" || bfl::die "Expected positive integer, received $2."

  local str_repeated
  # Create a string of spaces that is $multiplier long.
  str_repeated=$(printf "%${2}s") || bfl::die
  # Replace each space with the $str.
  str_repeated=${str_repeated// /"$1"}

  printf "%s" "$str_repeated"
  }
