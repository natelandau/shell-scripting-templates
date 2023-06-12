#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
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
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  local -r -a ARRAY_1=( "${!1:-}" )
  local -r -a ARRAY_2=( "${!2:-}" )

  local el s
  for el in "${ARRAY_1[@]}"; do
    for s in "${ARRAY_2[@]}"; do
      [[ "$el" == "$s" ]] && return 0
    done
  done

  return 1
  }
