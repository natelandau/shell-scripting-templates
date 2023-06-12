#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions for manipulating arrays
# @file
# Defines function: bfl::check_array_by_function_result_at_least_any_element().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Iterates over elements, returning true if any of the elements validate as true from the function.
#
# @param String $funcname
#   Function name to pass each item to for validation.
#
# @return Boolean $result
#   0 / 1  (true / false)
#
# @example
#		printf "%s\n" "${array[@]}" | bfl::check_array_by_function_result_at_least_any_element "bfl::is_integer"
#   bfl::check_array_by_function_result_at_least_any_element "bfl::is_integer" < <(printf "%s\n" "${array[@]}")
#------------------------------------------------------------------------------
bfl::check_array_by_function_result_at_least_any_element() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

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
      [[ $ret -eq 0 ]] && return 0
  done

  return 1
  }
