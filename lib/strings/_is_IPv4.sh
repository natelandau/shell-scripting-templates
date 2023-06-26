#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Bash Strings
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::is_IPv4().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Validates that input is a valid IP version 4 address.
#
# @param String $str
#   String to validate.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_IPv4 "192.168.1.1"
#------------------------------------------------------------------------------
bfl::is_IPv4() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local IFS=.
  # shellcheck disable=SC2206
  declare -a arr=("$1")
  [[ "$1" =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1

  # Test values of quads
  local quad
  for quad in {0..3}; do
      [[ ${arr["$quad"]} -gt 255 ]] && return 1
  done

  return 0
  }
