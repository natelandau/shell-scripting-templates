#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# --------------- https://github.com/dylanaraps/pure-bash-bible ---------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions to help work with dates and time
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_random_array_element().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints one random element from array.
#
# @param String $arr
#   Input array
#
# @return Boolean $el
#   An array element.
#
# @example
#   bfl::get_random_array_element "${arr[@]}"
#------------------------------------------------------------------------------
bfl::get_random_array_element() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; }              # Verify argument count.

  declare -a _arr
  local _arr=("$@")
  printf '%s\n' "${_arr[RANDOM % $#]}"

  return 0
  }
