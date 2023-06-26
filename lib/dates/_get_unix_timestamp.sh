#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions to help work with dates and time
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_Unix_timestamp().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Get the current time in unix timestamp.
#
# @return boolean $result
#   Prints result ~ 1591554426.
#
# @example
#   bfl::get_Unix_timestamp
#------------------------------------------------------------------------------
bfl::get_Unix_timestamp() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _now
  _now="$(date --universal +%s)" || return 1
  printf "%s\n" "${_now}"

  return 0
  }
