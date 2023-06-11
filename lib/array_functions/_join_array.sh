#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
# - http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array -
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions for manipulating arrays
# @file
# Defines function: bfl::join_array().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Joins items together with a user specified separator.
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
  bfl::verify_arg_count "$#" 2 2 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2" && return 1 # Verify argument count.

  local dlmtr="$1"
  printf "%s" "$2"

  printf "%s" "${@/#/$dlmtr}"
  }
