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
#		printf "%s\n" "${array[@]}" | bfl::check_array_by_function_result_at_least_any_element "bfl::is_alpha"
#   bfl::check_array_by_function_result_at_least_any_element "bfl::is_alpha" < <(printf "%s\n" "${array[@]}")
#------------------------------------------------------------------------------
bfl::check_array_by_function_result_at_least_any_element() {
  bfl::verify_arg_count "$#" 1 1 ||  # Verify argument count.
    echo "Missing required argument to ${FUNCNAME[0]}" && exit 1

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
