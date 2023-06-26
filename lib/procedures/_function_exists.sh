#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::function_exists().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Tests if a function exists in the current scope.
#
# @param String $func_name
#   Function name.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::function_exists "bfl::die"
#------------------------------------------------------------------------------
bfl::function_exists() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  if declare -f "$1" &>/dev/null 2>&1; then
      return 0
  fi

  bfl::writelog_debug "Did not find function: '$1'"
  return 1
  }
