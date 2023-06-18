#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to the internet
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::encode_html().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Encode HTML characters with sed.
# Must have a sed file containing replacements. See: ../../sedfiles/htmlEncode.sed
#
# @param String $str
#   The string to be encoded.
#
# @return String $rslt
#   The encoded string.
#
# @example
#   bfl::encode_html "string"
#------------------------------------------------------------------------------
bfl::encode_html() {
  bfl::verify_arg_count "$#" 1 1 ||  { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return $BFL_ErrCode_Not_verified_args_count; }      # Verify argument count.
  bfl::verify_dependencies "sed"  || { bfl::writelog_fail "${FUNCNAME[0]}: dependency sed not found."; return $BFL_ErrCode_Not_verified_dependency; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: empty string."; return $BFL_ErrCode_Not_verified_arg_values; }

  local _sedFile
  _sedFile=$(dirname "$BASH_FUNCTION_LIBRARY")/sedfiles/htmlEncode.sed
  [[ -f "${_sedFile}" ]] && { printf "%s" "${1}" | sed -f "${_sedFile}"; } || return 1

  return 0
  }
