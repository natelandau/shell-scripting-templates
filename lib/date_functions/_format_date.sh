#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions to help work with dates and time
#
# @file
# Defines function: bfl::format_date().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Reformats dates into user specified formats.
#
# @param String $str
#   Date to be formatted.
#
# @param String $str (optional)
#   Format in any format accepted by bash's date command. Defaults to YYYY-MM-DD or $(date +%F)
#   Examples:
#     %F - YYYY-MM-DD
#     %D - MM/DD/YY
#     %a - Name of weekday in short (like Sun, Mon, Tue, Wed, Thu, Fri, Sat)
#     %A - Name of weekday in full (like Sunday, Monday, Tuesday)
#         '+%m %d, %Y'  - 12 27, 2019
#
# @return boolean $result
#   Prints result.
#
# @example
#   bfl::format_date "Jan 10, 2019" "%D"
#------------------------------------------------------------------------------
#
bfl::format_date() {
  bfl::verify_arg_count "$#" 1 2 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [1, 2]"  # Verify argument count.

  local _format="${2:-%F}"
  _format="${_format//+/}"

  date -d "$1" "+${_format}"

  return 0
  }
