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
# Defines function: bfl::check_array_by_function_success_all_elements().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Iterates over elements and passes each to a function for validation. Iteration stops when the function returns 1.
#
# @param String $funcname
#   Function name to pass each item to.
#
# @return String $deduped_array
#   0 / 1  (true / false).      # Return code of called function
#
# @example
#		printf "%s\n" "${arr1[@]}" | bfl::check_array_by_function_success_all_elements "test_func"
#   bfl::check_array_by_function_success_all_elements "test_func" < <(printf "%s\n" "${arr1[@]}") #alternative approach
#------------------------------------------------------------------------------
bfl::check_array_by_function_success_all_elements() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local func="$1"
  local IFS=$'\n'
  local _it

  while read -r _it; do
      if [[ "$func" == *"$"* ]]; then
          eval "$func"
      else
          if declare -f "$func" &>/dev/null; then
              eval "$func" "'${_it}'"
          else
              bfl::writelog_fail "${FUNCNAME[0]} could not find function $func"
              return 1
          fi
      fi
      local -i ret="$?"

      [[ $ret -eq 0 ]] || return ${ret}
  done

  return 0
  }
