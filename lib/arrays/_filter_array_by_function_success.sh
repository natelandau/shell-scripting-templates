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
# Defines function: bfl::filter_array_by_function_success().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Iterates over elements, returning only those that are validated by a function.
#
# @param String $funcname
#   Function name to pass each item to for validation.
#
# @return Boolean $rslt
#   0 / 1   true/ false.  Values matching the validation function.
#
# @example
#   printf "%s\n" "${array[@]}" | bfl::filter_array_by_function "bfl::is_integer"
#   bfl::filter_array_by_function_success "bfl::is_integer" < <(printf "%s\n" "${array[@]}")
#------------------------------------------------------------------------------
bfl::filter_array_by_function_success() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local func="${1}"
  local IFS=$'\n'
  local _it

  while read -r _it; do
      if [[ $func == *"$"* ]]; then
          eval "$func"
      else
          eval "$func" "'${_it}'"
      fi

      local -i ret="$?"
      [[ $ret -eq 0 ]] && printf "%s\n" "${_it}"
  done

  return 0
  }
