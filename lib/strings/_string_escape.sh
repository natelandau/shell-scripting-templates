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
# Defines function: bfl::string_escape().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Escapes all special characters in STRING.
#
# @param String $STRING
#   The string to escape values in.
#
# @return String $result
#   String with escaped special characters.
#
# @example
#   bfl::string_escape "Some text"
#------------------------------------------------------------------------------
bfl::string_escape() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  bfl::is_blank "$1" && { echo ''; return 0; }

  printf -v var '%q\n' "$1"
  echo "$var"

#----------- https://github.com/natelandau/shell-scripting-templates ----------
#    printf "%s\n" "${@}" | sed 's/[]\.|$[ (){}?+*^]/\\&/g'
  return 0
  }
