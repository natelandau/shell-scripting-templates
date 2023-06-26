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
# Defines function: bfl::get_OS_name().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns the OS name as written in '/etc/os-release'.
#
# @return String   $name
#   Value of the 'NAME' attribute.
#
# @example
#   bfl::get_OS_name
#------------------------------------------------------------------------------
bfl::get_OS_name() {
  bfl::verify_arg_count "$#" 0 0   || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0";   return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  [[ -f /etc/os-release ]] || { bfl::writelog_fail "${FUNCNAME[0]}: /etc/os-release doesn't exists!"; return 1; }
  # Verify argument values.

  echo "$( . /etc/os-release && echo ${NAME} )"

  return 0
  }
