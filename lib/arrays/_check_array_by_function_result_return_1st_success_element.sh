#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to bash arrays
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::check_array_by_function_result_return_1st_success_element().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Iterates over elements, returning success and printing the first value that is validated by a function.
#
# @param String $funcname
#   (Required) - Function name to pass each item to for validation. (Must return 0 on success).
#
# @return Boolean $rslt
#     0 / 1   ( true / false ). First value that is validated by the function.
#
# @example
#	  printf "%s\n" "${array[@]}" | check_array_by_function_result_return_1st_success_element "bfl::is_integer"
#   bfl::check_array_by_function_result_return_1st_success_element "bfl::is_integer" < <(printf "%s\n" "${array[@]}")
#------------------------------------------------------------------------------
bfl::check_array_by_function_result_return_1st_success_element() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

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
      if [[ $ret -eq 0 ]]; then
          printf "%s" "${_it}"
          return 0
      fi
  done

  return 1
  }
