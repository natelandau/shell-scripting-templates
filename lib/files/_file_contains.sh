#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::file_contains().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Searches a file for a given pattern using default grep patterns.
#
# @param String $file
#   Input file.
#
# @param String $regex
#   Pattern to search for.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::file_contains "./file.sh" "^[:alpha:]*"
#------------------------------------------------------------------------------
bfl::file_contains() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$1" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: path doesn't exists!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -z "$2" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: regex is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  #       text file
  grep -q "$2" "$1"

  return 0
  }
