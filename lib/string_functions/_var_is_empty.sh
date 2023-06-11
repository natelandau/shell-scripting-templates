#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::var_is_empty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Check if a given variable is false.
#
# @param String $str
#   Variable to check.
#
# @return boolean $result
#        0 / 1 (true / false)
#
# @example
#   bfl::var_is_empty "$var"
#------------------------------------------------------------------------------
#
bfl::var_is_empty() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  [[ -z "$1" || "${1,,}" =~ ^null$ ]] && return 0 || return 1
  }