#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------ https://github.com/labbots/bash-utility/src/date.sh ------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions to help work with dates and time
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::unix_timestamp_to_date_string().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Format unix timestamp to human readable format. If format string is not specified then default to "yyyy-mm-dd hh:mm:ss".
#
# @param Integer $timestamp
#   Unix timestamp to be formatted.
#
# @param String $format (optional)
#   Format string.
#
# @return String $result
#   Human readable format of unix timestamp.
#
# @example
#   printf "%s\n" "$(bfl::unix_timestamp_to_date_string "Jan 10, 2019")"
#     bfl::unix_timestamp_to_date_string "1591554426"
#     bfl::unix_timestamp_to_date_string "1591554426" "%Y-%m-%d"
#------------------------------------------------------------------------------
bfl::unix_timestamp_to_date_string() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local format="${2:-"%F %T"}"
  local out
  out="$(date -d "@$1" +"$format")" || return 1
  printf "%s\n" "$out"

  return 0
  }
