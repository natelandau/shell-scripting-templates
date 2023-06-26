#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Bash Strings
#
#
#
# @file
# Defines function: bfl::fix_PATH_colons().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Replaces :: => : and trims right and left sides from the beginning and the end of string.
#   The string ONLY single line
#
# @param String $str
#   The string to fixed.
#
# @return String $str
#   The fixed path.
#
# @example
#   bfl::fix_PATH_colons $LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::fix_PATH_colons() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local str
  str=$(echo "$1" | sed 's/::*/:/g')
  str=$(bfd::trimLR "$str" ':' ' ')

  echo "$str"
  return 0
  }
