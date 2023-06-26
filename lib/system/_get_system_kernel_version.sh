#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Linux Systems
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::get_system_kernel_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns the version string of the currently running kernel.
#
# @return String  $result
#   Version string (e.g. "4.4.39-gentoo")
#
# @example
#   bfl::get_system_kernel_version
#------------------------------------------------------------------------------
bfl::get_system_kernel_version() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local str
  str="$( uname -r )"

  echo "$str"
  return 0
  }
