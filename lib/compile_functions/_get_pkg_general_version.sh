#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# @file
# Defines function: bfl::_get_pkg_general_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Upper version: 2.35.1-dfg => 2.35
#
# @param string $path
#   Package version.
#
# @return string $version
#   Upper version.
#
# @example
#   bfl::_get_pkg_general_version "2.35.1-dfg"
#------------------------------------------------------------------------------
bfl::_get_pkg_general_version() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  local n=`echo "$1" | tr -cd '.' | wc -m` # сколько точек в версии файла
  ((n<2)) && echo "$1" && return 0

  local str=`echo "$1" | sed 's/\(.*\..*\)\..*/\1/'`
  echo "$str"
  return 0
  }
