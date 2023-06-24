#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------- https://gist.github.com/cdown/1163649 -------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to the internet
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::decode_url().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Decodes a URL decoded string.
#
# @param String $str
#   The string to be decoded.
#
# @return String $rslt
#   The decoded string.
#
# @example
#   bfl::decode_url "foo bar"
#------------------------------------------------------------------------------
bfl::decode_url() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; }     # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: empty string."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local _url_encoded="${1//+/ }"
  printf '%b' "${_url_encoded//%/\\x}"

  return 0
  }
