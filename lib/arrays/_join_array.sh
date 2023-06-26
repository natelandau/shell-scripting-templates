#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
# - http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array -
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to bash arrays
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::join_array().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Joins items together with a user specified separator.
#
# @param String $Separator
#   Separator.
#
# @param Array $Array or space separated items to be joined
#   Array.
#
# @return String $rslt
#   Prints joined terms.
#
# @example
#   bfl::join_array , a "b c" d #a,b c,d
#   bfl::join_array / var local tmp #var/local/tmp
#   bfl::join_array , "${foo[@]}" #a,b,c
#------------------------------------------------------------------------------
bfl::join_array() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1..999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local dlmtr="$1"
  printf "%s" "$2"

  printf "%s" "${@/#/$dlmtr}"
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#  result="$( printf "${DELIMITER}%s" "${ARRAY[@]}" )"  # Concatenate the array elements, using wit DELIMITER as prefix to _every_ element
#  result="${result:${#DELIMITER}}" # Remove leading DELIMITER
  }
