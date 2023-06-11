#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions for manipulating arrays
# @file
# Defines function: bfl::filter_array_by_function_code_1().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# The opposite of bfl::for_each_filter. Iterates over elements, returning only those that are not validated by a function.
#
# @param String $funcname
#   Function name to pass each item to for validation.
#
# @return Boolean $result
#   0 / 1  (true / false).  Values NOT matching the validation function
#
# @example
#   printf "%s\n" "${array[@]}" | bfl::filter_array_by_function_code_1 "bfl::is_integer"
#   bfl::filter_array_by_function_code_1 "bfl::is_integer" < <(printf "%s\n" "${array[@]}")
#------------------------------------------------------------------------------
bfl::filter_array_by_function_code_1() {
  bfl::verify_arg_count "$#" 1 1 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1" && return 1 # Verify argument count.

  local func="$1"
  local IFS=$'\n'
  local _it

  while read -r _it; do
      if [[ "$func" == *"$"* ]]; then
          eval "$func"
      else
          eval "$func" "'${_it}'"
      fi

      local -i ret="$?"
      [[ $ret -ne 0 ]] && printf "%s\n" "${_it}"
  done
  }
