#!/usr/bin/env bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
#
#
# @file
# Defines function: bfl::print_function_stack().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints the function stack in use. Used for debugging, and error reporting.
#
# @return Boolean $result
#   Prints [function]:[file]:[line]. Does not print functions from the alert class.
#
# @example
#   bfl::print_function_stack
#------------------------------------------------------------------------------
bfl::print_function_stack() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  local -a _funcStackResponse=()
  local -i i=0
  for ((i = 1; i < ${#BASH_SOURCE[@]}; i++)); do
      _funcStackResponse+=("${FUNCNAME[$i]}:$(basename "${BASH_SOURCE[$i]}"):${BASH_LINENO[$i-1]}")
  done

  printf "( "
  printf %s "${_funcStackResponse[0]}"
  printf ' < %s' "${_funcStackResponse[@]:1}"
  printf ' )\n'

  return 0
  }
