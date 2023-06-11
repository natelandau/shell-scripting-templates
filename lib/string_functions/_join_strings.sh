#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::join_strings().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Joins multiple strings into a single string, separated by another string.
#
# This function will accept an unlimited number of arguments.
# Example: bfl::join_strings "," "foo" "bar" "baz"
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
#   bfl::join_strings "," "foo" "bar" "baz"
#-----------------------------------------------------------------------------
bfl::join_strings() {
  bfl::verify_arg_count "$#" 2 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  local -r glue="$1"

  shift  # Delete the first positional parameter.
  # Create the pieces array from the remaining positional parameters.
  local -a pieces=("$@")
  local jstring

  while (( "${#pieces[@]}" )); do
      if [[ "${#pieces[@]}" -eq "1" ]]; then
          jstring+=$(printf "%s\\n" "${pieces[0]}") || { bfl::writelog_fail "${FUNCNAME[0]}: jstring += \$(printf %s\\n \${pieces[0]} )"; return 1; }
      else
          jstring+=$(printf "%s%s" "${pieces[0]}" "$glue") || { bfl::writelog_fail "${FUNCNAME[0]}: jstring += \$(printf %s\\n \${pieces[0]} $glue)"; return 1; }
      fi
      pieces=("${pieces[@]:1}")   # Shift the first element off of the array.
  done

  printf "%s" "$jstring"
  }