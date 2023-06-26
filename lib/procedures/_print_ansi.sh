#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ----- https://github.com/labbots/bash-utility/blob/master/src/debug.sh ------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::print_ansi().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Helps debug ansi escape sequence in text by displaying the escape codes.
#
# @param String $str
#   String input with ansi escape sequence.
#
# @return String $rslt
#   Ansi escape sequence printed in output as is.
#
# @example
#   bfl::print_ansi "$(tput bold)$(tput setaf 9)Some Text"
#------------------------------------------------------------------------------
bfl::print_ansi() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  #printf "%s\n" "$(tr -dc '[:print:]'<<<$1)"
  printf "%s\n" "${1//$'\e'/\\e}"
  }
