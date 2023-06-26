#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh
#
# Library of functions related to Linux Systems
#
#
#
# @file
# Defines function: bfl::is_system_x86_64().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Determines x86_64 architecture
#
# @return Boolean   $value
#   if getconf is available, it will return the arch of the OS, as desired
#   if not, it will use uname to get the arch of the CPU, though the installed
#   OS could be 32-bits on a 64-bit CPU
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_system_x86_64
#------------------------------------------------------------------------------
bfl::is_system_x86_64() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  [ "$(bfl::get_system_32_64bit)" = 64 -a "$(bfl::get_system_architecture)" = "x86" ]
  }
