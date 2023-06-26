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
# Defines function: bfl::get_available_kernel().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Returns the string representation of an array of all kernel sources available in '/usr/src' (lowest first, highest last).
#
# @return String  $result
#   String representation of an array (e.g. '( [0]="4.16.18-gentoo" [1]="4.17.13-gentoo" [2]="4.17.14-gentoo" )').
#
# @example
#   bfl::get_available_kernel
#------------------------------------------------------------------------------
bfl::get_available_kernel() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # List all kernel sources folders, sort their base names naturally (the lowest version first, the highest last) and remove the 'linux-' prefix
  local s
  s=( $( find /usr/src/ -maxdepth 1 -name 'linux-*' -type d -print0 | xargs --null --max-args=1 basename | sort --version-sort | sed -e 's/^linux-//' ) ) ||  { bfl::writelog_fail "${FUNCNAME[0]} error find /usr/src/ -maxdepth 1 -name 'linux-*' -type d -print0 | xargs --null --max-args=1 basename | sort --version-sort | sed -e 's/^linux-//' )"; return 1; }

  # Serialize the array ('declare -p' prints out the array constructor, which then is stripped down to the array string)
  local -r serialized=$( declare -p s )
  printf "${serialized#*=}"
  return 0
  }
