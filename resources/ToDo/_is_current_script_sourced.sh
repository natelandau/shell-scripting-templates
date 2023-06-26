#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::is_current_script_sourced().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Clears output in the terminal up to the specified line number.
#
# @param String $Line_No  (Optional)
#   Line number to clear. (Defaults to 1)
#
# @return Boolean $result
#   0 / 1   true / false
#
# @example
#   bfl::is_current_script_sourced 2
#------------------------------------------------------------------------------
bfl::is_current_script_sourced() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return 1; }              # Verify argument count.
  [[ ${_} != "$0" ]] && local i=1 || local i=0
  echo "${BASH_SOURCE[$i]}"

  return 0
  }
