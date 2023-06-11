#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::fix_PATH_colons().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Replaces :: => : and trims right and left sides from the beginning and the end of string.
#
# The string ONLY single line
#
# @param string $str
#   The string to fixed.
#
# @return string $str
#   The fixed path.
#
# @example
#   bfl::fix_PATH_colons $LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::fix_PATH_colons() {
  bfl::verify_arg_count "$#" 1 1 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1" && return 1 # Verify argument count.

  local str
  str=$(echo "$1" | sed 's/::*/:/g')
  str=$(bfd::trimLR "$str" ':' ' ')

  echo "$str"
  return 0
  }
