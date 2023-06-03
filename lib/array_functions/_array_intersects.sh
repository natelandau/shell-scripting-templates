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
# Defines function: bfl::array_intersects().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks, if ARRAY_1 and ARRAY_2 have one or more elements in common.
#
# @param Array    ARRAY_1
#   The array to test.
#
# @param Array    ARRAY_2
#   The array to test.
#
# @return Boolan $result
#      0 / 1 (true / false).
#
# @example
#   bfl::array_intersects ARRAY_1[@] ARRAY_2[@]
#------------------------------------------------------------------------------
#
bfl::array_intersects() {
  bfl::verify_arg_count "$#" 2 2 || exit 1  # Verify argument count.

  local -r -a ARRAY_1=( "${!1:-}" )
  local -r -a ARRAY_2=( "${!2:-}" )

  local i j
  for i in "${ARRAY_1[@]}"; do
    for j in "${ARRAY_2[@]}"; do
      [[ $i == "$j" ]] && return 0
    done
  done

  return 1
  }
