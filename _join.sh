#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::join().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Joins multiple strings into a single string, separated by another string.
#
# This function will accept an unlimited number of arguments.
# Example: bfl::join "," "foo" "bar" "baz"
#
# @param string $glue
#   The character or characters that will be used to glue the strings together.
# @param list $pieces
#   The list of strings to be combined.
#
# @return string $joined_string
#   The joined string.
#
# @example
#   bfl::join "," "foo" "bar" "baz"
#-----------------------------------------------------------------------------
bfl::join() {
  bfl::verify_arg_count "$#" 2 999 || exit 1

  declare -r glue="$1"

  # Delete the first positional parameter.
  shift

  # Create the pieces array from the remaining positional parameters.
  declare -a pieces=("$@")
  declare joined_string

  while (( "${#pieces[@]}" )); do
    if [[ "${#pieces[@]}" -eq "1" ]]; then
      joined_string+=$(printf "%s\\n" "${pieces[0]}") || bfl::die
    else
      joined_string+=$(printf "%s%s" "${pieces[0]}" "${glue}") || bfl::die
    fi
    pieces=("${pieces[@]:1}")   # Shift the first element off of the array.
  done

  printf "%s" "${joined_string}"
}
