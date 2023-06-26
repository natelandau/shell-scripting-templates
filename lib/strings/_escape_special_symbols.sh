#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Bash Strings
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::escape_special_symbols().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Escapes all special characters in string.
#
# @param String $value
#   The string to be tested.
#
# @return Boolean $result
#   String with escaped special characters.
#
# @example
#   bfl::escape_special_symbols "some string"
#------------------------------------------------------------------------------
bfl::escape_special_symbols() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  [[ -z "$1" ]] && echo '' && return 0

  printf -v var '%q\n' "$1"
  echo "$var"
  }
