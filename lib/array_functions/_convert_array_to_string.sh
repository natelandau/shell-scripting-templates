#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to bash arrays
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::convert_array_to_string().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns a String composed of the array elements joined together with a the specified delimiter.
#
# @param Array    ARRAY
#   The array to join together.
#
# @param Array    DELIMITER
#   A sequence of characters that is used to separate each of the elements in the resulting String (default: ",").
#
# @return String $result
#      String with all elements of ARRAY joined.
#
# @example
#   bfl::convert_array_to_string ARRAY[@] "${DELIMITER}"
#------------------------------------------------------------------------------
#
bfl::convert_array_to_string() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  # Verify argument values.
  ( [ -z ${1+x} ] || [ -z "$1" ] ) && return 1

  local -r -a ARRAY=( "${!1:-}" )
  local -r DELIMITER="${2:-,}"

  # Concatenate the array elements, using wit DELIMITER as prefix to _every_ element
  result="$( printf "${DELIMITER}%s" "${ARRAY[@]}" )"

  # Remove leading DELIMITER
  result="${result:${#DELIMITER}}"

  echo "$result"
  return 0
  }
