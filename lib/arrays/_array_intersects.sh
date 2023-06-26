#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
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
#   Checks, if array1 and array2 have one or more elements in common.
#
# @param Array $array1
#   The array to test.
#
# @param Array $array2
#   The array to test.
#
# @return Boolean $result
#      0 / 1 (true / false).
#
# @example
#   bfl::array_intersects array1[@] array2[@]
#------------------------------------------------------------------------------
bfl::array_intersects() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r -a array1=( "${!1:-}" )
  local -r -a array2=( "${!2:-}" )

  local el s
  for el in "${array1[@]}"; do
    for s in "${array2[@]}"; do
      [[ "$el" == "$s" ]] && return 0
    done
  done

  #ARRAY_3=($(comm -12 <(printf '%s\n' "${!ARRAY_1}" | LC_ALL=C sort) <(printf '%s\n' "${!ARRAY_2}" | LC_ALL=C sort)))
  #echo ${ARRAY_3[@]}

  return 1
  }
