#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------ https://github.com/labbots/bash-utility/src/date.sh ------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions to help work with dates and time
#
# @file
# Defines function: bfl::unix_timestamp_to_date_string().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Format unix timestamp to human readable format. If format string is not specified then default to "yyyy-mm-dd hh:mm:ss".
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
#
bfl::unix_timestamp_to_date_string() {
  bfl::verify_arg_count "$#" 1 2 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]" && return 1 # Verify argument count.

  local format="${2:-"%F %T"}"
  local out
  out="$(date -d "@$1" +"$format")" || return 1
  printf "%s\n" "$out"

  return 0
  }
