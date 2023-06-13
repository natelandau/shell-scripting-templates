#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Bash Strings
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::string_escape().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns the string representation of an array, containing all fragments of STRING splitted using REGEX.
#
# @param string $STRING
#   The string to escape values in.
#
# @return String $result
#   String with escaped special characters.
#
# @example
#   bfl::string_escape
#------------------------------------------------------------------------------
bfl::string_escape() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  bfl::is_blank "$1" && { echo ''; return 0; }

  printf -v var '%q\n' "$1"
  echo "$var"
  }