#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::repeat().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Repeats a string.
#
# @param string $str
#   The string to be repeated.
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
  bfl::verify_arg_count "$#" 2 2 || exit 1

  declare -r str="$1"
  declare -r multiplier="$2"
  declare str_repeated

  bfl::is_positive_integer "${multiplier}" \
    || bfl::die "Expected positive integer, received ${multiplier}."

  # Create a string of spaces that is $multiplier long.
  str_repeated=$(printf "%${multiplier}s") || bfl::die
  # Replace each space with the $str.
  str_repeated=${str_repeated// /"${str}"}

  printf "%s" "${str_repeated}"
}
