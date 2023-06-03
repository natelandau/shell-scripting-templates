#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to bash arrays
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::array_contains_element().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks, if the array contains the element.
#
# @param Array    ARRAY
#   The array to test (technically it is a string and the name of the array).
#
# @param Object   ELEMENT
#   The element to find.
#
# @return Boolan $result
#      0 / 1 (true / false).
#
# @example
#   bfl::array_contains_element ARRAY[@] "${ELEMENT}"
#------------------------------------------------------------------------------
#
bfl::array_contains_element() {
  bfl::verify_arg_count "$#" 2 2 || exit 1  # Verify argument count.

  local -r -a ARRAY=( "${!1:-}" )
  local -r ELEMENT="${2:-}"

  for i in "${ARRAY[@]}"; do
    [[ "${i}" == "${ELEMENT}" ]] && return 0
  done

  return 1
  }
