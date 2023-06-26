#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to directories manipulation
#
#
#
# @file
# Defines function: bfl::unforward_links().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the files in a directory (recursively or not).
#
# @param String $path1
#   A directory with files.
#
# @param String $path2
#   A directory with file links.
#
# @example
#   bfl::unforward_links  /tools/binutils-2.40 /usr/local
#------------------------------------------------------------------------------
bfl::unforward_links() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  }
