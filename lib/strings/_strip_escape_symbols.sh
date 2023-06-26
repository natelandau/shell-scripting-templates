#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Bash Strings
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::strip_escape_symbols().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Strips ANSI escape sequences from a string.
#
# @param String $str
#   String to be cleaned.
#
# @return String $rslt
#   Prints string with ANSI escape sequences removed.
#
# @example
#   bfl::strip_escape_symbols "\e[1m\e[91mThis is bold red text\e(B\e[m.\e[92mThis is green text.\e(B\e[m"
#------------------------------------------------------------------------------
bfl::strip_escape_symbols() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  local _tmp _esc _tpa _re
  _tmp="${1}"
  _esc=$(printf "\x1b")
  _tpa=$(printf "\x28")
  _re="(.*)${_esc}[\[${_tpa}][0-9]*;*[mKB](.*)"
  while [[ ${_tmp} =~ ${_re} ]]; do
      _tmp="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
  done
  printf "%s" "${_tmp}"

  return 0
  }
