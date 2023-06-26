#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Linux Systems
#
#
#
# @file
# Defines function: bfl::get_CPU_cores().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Determines the CPU's cores number (from /usr/share/bash_completion)
#
# @return Integer $Number
#   The number of CPU cores.
#
# @example
#   bfl::get_CPU_cores
#------------------------------------------------------------------------------
bfl::get_CPU_cores() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local os
  os=$(bfl::get_OS) || { bfl::writelog_fail "${FUNCNAME[0]}: os=bfl::get_OS error!"; return 1; }
#  [[ "$OSTYPE"  == 'linux' ]]
  [[ "$os" == 'linux' ]] || { bfl::writelog_fail "${FUNCNAME[0]}: current system is not Linux!"; return 1; }

  local n var="_NPROCESSORS_ONLN"
  n=$(getconf "$var")
  printf %i ${n:-1}

  return 0
  }
