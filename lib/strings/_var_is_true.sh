#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Bash Strings
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::var_is_true().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Check if a given variable is true.
#
# @param String $str
#   Variable to check.
#
# @return boolean $result
#      0 / 1   ( true / false )
#
# @example
#   bfl::var_is_true "$var"
#------------------------------------------------------------------------------
bfl::var_is_true() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  [[ ${1} -eq 0 || "${1,,}" =~ ^true|yes$ ]] && return 0 || return 1
  }
