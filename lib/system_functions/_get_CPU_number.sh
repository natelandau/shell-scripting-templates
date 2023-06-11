#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::get_CPU_number().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines the CPU's cores number (from /usr/share/bash_completion)
#
# @return Integer $Number
#   The number of CPU cores.
#
# @example
#   bfl::get_CPU_number
#------------------------------------------------------------------------------
bfl::get_CPU_number() {
  bfl::verify_arg_count "$#" 0 0 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0" && return 1 # Verify argument count.

  local n var=NPROCESSORS_ONLN
  [[ $OSTYPE == *linux* ]] && var=_$var
  n=$(getconf $var 2>/dev/null)
  printf %s ${n:-1}

  return 0
  }
