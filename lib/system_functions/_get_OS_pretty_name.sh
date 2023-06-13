#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Linux Systems
#
# @file
# Defines function: bfl::get_OS_pretty_name().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns the OS name as written in '/etc/os-release'.
#
# @return String   $name
#   Value of the 'PRETTY_NAME' attribute.
#
# @example
#   bfl::get_OS_pretty_name
#------------------------------------------------------------------------------
bfl::get_OS_pretty_name() {
  bfl::verify_arg_count "$#" 0 0   || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0";   return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  [[ -f /etc/os-release ]] || { bfl::writelog_fail "${FUNCNAME[0]}: /etc/os-release doesn't exists!"; return 1; }
  # Verify argument values.

  echo "$( . /etc/os-release && echo ${PRETTY_NAME} )"

  return 0
  }
