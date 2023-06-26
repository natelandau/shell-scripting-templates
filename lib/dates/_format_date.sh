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
# Defines function: bfl::format_date().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Reformats dates into user specified formats.
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
bfl::format_date() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _format="${2:-%F}"
  _format="${_format//+/}"

  date -d "$1" "+${_format}"

  return 0
  }
