#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
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
  bfl::verify_arg_count "$#" 2 999 || exit 1  # Verify argument count.

  local -r glue="$1"

  shift  # Delete the first positional parameter.
  # Create the pieces array from the remaining positional parameters.
  declare -a pieces=("$@")
  local joined_string

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
