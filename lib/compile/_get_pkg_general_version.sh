#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of useful utility functions for compiling sources
#
#
#
# @file
# Defines function: bfl::_get_pkg_general_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Upper version: 2.35.1-dfg => 2.35
#
# @param String $path
#   Package version.
#
# @return String $version
#   Upper version.
#
# @example
#   bfl::_get_pkg_general_version "2.35.1-dfg"
#------------------------------------------------------------------------------
bfl::_get_pkg_general_version() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local n=`echo "$1" | tr -cd '.' | wc -m` # сколько точек в версии файла
  ((n<2)) && echo "$1" && return 0

  local str=`echo "$1" | sed 's/\(.*\..*\)\..*/\1/'`
  echo "$str"
  return 0
  }
