#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions to help work with dates and time
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::date_string_to_seconds().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Converts HH:MM:SS to seconds.
#
# @param String $str
#   Time in HH:MM:SS.
#
# @return Integer $seconds
#   Print seconds.
#
# @example
#   bfl::date_string_to_seconds "01:00:00"
#   Acceptable Input Formats
#     24 12 09
#     12,12,09
#     12;12;09
#     12:12:09
#     12-12-09
#     12H12M09S
#     12h12m09s
#------------------------------------------------------------------------------
bfl::date_string_to_seconds() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local saveIFS
  local -i h m s

  if [[ "$1" =~ [0-9]{1,2}(:|,|-|_|,| |[hHmMsS])[0-9]{1,2}(:|,|-|_|,| |[hHmMsS])[0-9]{1,2} ]]; then
      saveIFS="$IFS"
      IFS=":,;-_, HhMmSs" read -r h m s <<<"$1"
      IFS="$saveIFS"
  else
      h="$1"; m="$2"; s="$3"
  fi

  printf "%s\n" "$((10#$h * 3600 + 10#$m * 60 + 10#$s))"

  return 0
  }
