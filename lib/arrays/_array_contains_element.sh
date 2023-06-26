#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to bash arrays
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::array_contains_element().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks, if the array contains the element.
#
# @param Array    ARRAY
#   The array to test (technically it is a string and the name of the array).
#
# @param Object   ELEMENT
#   The element to find.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::array_contains_element ARRAY[@] "${ELEMENT}"
#------------------------------------------------------------------------------
bfl::array_contains_element() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r -a arr=( "${!1:-}" )
  local -r sEl="${2:-}"
  local el
  for el in "${arr[@]}"; do
    [[ "$el" == "$sEl" ]] && return 0
  done

  return 1
  }
