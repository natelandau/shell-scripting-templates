#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of useful utility functions for compiling sources
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::is_pkg_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Tests if STRING is a version string .
#
# @param String $value_to_test
#   The value to be tested.
#
# @return Boolean $result
#      0 / 1 (true / false).
#
# @example
#   bfl::is_pkg_version "1.0.0-SNAPSHOT"
#------------------------------------------------------------------------------
bfl::is_pkg_version() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r argument="$1"

  ! [[ "${argument}" =~ ^[[:digit:]]+(\.[[:digit:]]+){0,2}(-[[:alnum:]]+)?$ ]] && return 1
  return 0
  }
