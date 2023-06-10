#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
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
# @return boolean $result
#        0 / 1 (true / false)
#
# @example
#   bfl::function_exists "bfl::die"
#------------------------------------------------------------------------------
#
bfl::function_exists() {
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.

  if declare -f "$1" &>/dev/null 2>&1; then
      return 0
  else
      return 1
  fi
  }
