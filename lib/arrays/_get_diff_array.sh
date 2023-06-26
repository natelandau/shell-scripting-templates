#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ----------------- http://stackoverflow.com/a/1617303/142339 -----------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to bash arrays
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_diff_array().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Return items that exist in ARRAY1 that are do not exist in ARRAY2.
#   Note that the arrays must be passed in as strings
#
# @param Array $Array or space separated items to be compared
#   Array 1 (in format ARRAY[@]).
#
# @param Array $Array or space separated items to be compared
#   Array 2 (in format ARRAY[@]).
#
# @return Boolean $rslt
#   0 / 1   (true / false)  0 - if unique elements found, 1 if arrays are the same
#
# @example
#   bfl::get_diff_array "array1[@]" "array2[@]"
#   mapfile -t NEW_ARRAY < <(bfl::get_diff_array "array1[@]" "array2[@]")
#------------------------------------------------------------------------------
bfl::get_diff_array() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _skip _a _b
  local -a _setdiffA=("${!1}")
  local -a _setdiffB=("${!2}")
  local -a _setdiffC=()

  for _a in "${_setdiffA[@]}"; do
      _skip=0
      for _b in "${_setdiffB[@]}"; do
          [[ ${_a} == "${_b}" ]] && { _skip=1; break; }
      done
      [[ ${_skip} -eq 1 ]] || _setdiffC=("${_setdiffC[@]}" "${_a}")
  done

  [[ ${#_setdiffC[@]} -eq 0 ]] && return 1  # arrays are equal

  printf "%s\n" "${_setdiffC[@]}"
  }
