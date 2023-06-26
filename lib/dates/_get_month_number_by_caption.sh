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
# Defines function: bfl::get_month_number_by_caption().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Convert a month name to a number.
#
# @param String $MonthName
#   Month name.
#
# @return Integer $result
#   Prints the number of the month (1-12).
#
# @example
#   bfl::get_month_number_by_caption "January"
#------------------------------------------------------------------------------
bfl::get_month_number_by_caption() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: Month name is blank!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local month="${1,,}" # "$(echo "$1" | tr '[:upper:]' '[:lower:]')"

  case "$month" in
      january | jan | ja) echo 1 ;;
      february | feb | fe) echo 2 ;;
      march | mar | ma) echo 3 ;;
      april | apr | ap) echo 4 ;;
      may) echo 5 ;;
      june | jun | ju) echo 6 ;;
      july | jul) echo 7 ;;
      august | aug | au) echo 8 ;;
      september | sep | se) echo 9 ;;
      october | oct | oc) echo 10 ;;
      november | nov | no) echo 11 ;;
      december | dec | de) echo 12 ;;
      *)
          warning "_monthToNumber_: Bad month name: $month"
          return 1
          ;;
  esac

  return 0
  }
