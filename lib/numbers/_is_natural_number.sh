#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to strings as numbers
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::is_natural_number().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Determines if the argument is a natural number.
#
# @param String $value_to_test
#   The value to be tested.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_natural_number "8675309"
#------------------------------------------------------------------------------
bfl::is_natural_number() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

#             ${regex}
  [[ "$1" =~ ^[+]?[0-9]+$ ]] && return 0
  return 1
  }
