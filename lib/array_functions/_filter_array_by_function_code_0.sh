#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions for manipulating arrays
# @file
# Defines function: bfl::filter_array_by_function_code_0().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Iterates over elements, returning only those that are validated by a function.
#
# @param String $funcname
#   (Required) - Function name to pass each item to for validation. (Must return 0 on success).
#
# @return Boolean $rslt
#   0 / 1   true/ false.  Values matching the validation function.
#
# @example
# printf "%s\n" "${array[@]}" | bfl::filter_array_by_function "bfl::is_alpha"
# bfl::filter_array_by_function_code_0 "bfl::is_alpha" < <(printf "%s\n" "${array[@]}")
#------------------------------------------------------------------------------
bfl::filter_array_by_function_code_0() {
  bfl::verify_arg_count "$#" 1 1 ||  # Verify argument count.
    echo "Missing required argument to ${FUNCNAME[0]}" && exit 1

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
