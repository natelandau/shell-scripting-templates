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
# Defines function: bfl::get_month_caption_by_number().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Convert a month number to its name.
#
# @param Integer $MonthNo
#   Month number (1-12).
#
# @return String $result
#   Prints the name of the month.
#
# @example
#   bfl::get_month_caption_by_number 11
#------------------------------------------------------------------------------
bfl::get_month_caption_by_number() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  case "$1" in
      1 | 01) echo January ;;
      2 | 02) echo February ;;
      3 | 03) echo March ;;
      4 | 04) echo April ;;
      5 | 05) echo May ;;
      6 | 06) echo June ;;
      7 | 07) echo July ;;
      8 | 08) echo August ;;
      9 | 09) echo September ;;
      10) echo October ;;
      11) echo November ;;
      12) echo December ;;
      *)
          warning "_numberToMonth_: Bad month number: $1"
          return 1
          ;;
  esac

  return 0
  }
