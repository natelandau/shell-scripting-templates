#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------- https://gist.github.com/cdown/1163649 -------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to the internet
#
# @author  Nathaniel Landau, A. River
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

  local url_decoded="${1//+/ }"
  printf '%b' "${url_decoded//%/\\x}"

# ----------------- https://github.com/ariver/bash_functions ------------------
#  local ent str
#  for ent in "${@}"; do
#      str="$( echo "${ent}" | sed "y/+/ /;s/%25/%/g;s/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g" )"
#      printf "$str"
#  done

  return 0
  }
