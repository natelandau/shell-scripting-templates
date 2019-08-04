#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::str_repeat().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Repeats a string.
#
# @param string $input
#   The string to be repeated.
# @param int $multiplier
#   Number of times the string will be repeated.
#
# @return string $result
#   The repeated string.
#------------------------------------------------------------------------------
bfl::str_repeat() {
  bfl::verify_arg_count "$#" 2 2 || exit 1

  declare -r input="$1"
  declare -r multiplier="$2"
  declare result

  if ! bfl::is_integer "${multiplier}"; then
    bfl::die "Error: \$multiplier is not a positive integer."
  fi

  # Create a string of spaces that is $multiplier long.
  result=$(printf "%${multiplier}s") || bfl::die
  # Replace each space with the $input.
  result=${result// /"${input}"}

  printf "%s" "${result}"
}
