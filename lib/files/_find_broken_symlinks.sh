#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  A. River
#
# @file
# Defines function: bfl::find_broken_symlinks().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Searches broken symlinks.
#
# @param String $path (optional)
#   Directory to search broken symlinks. (Default is current directory)
#
# @return String $result
#   Files list.
#
# @example
#   bfl::find_broken_symlinks /path
#------------------------------------------------------------------------------
bfl::find_broken_symlinks() {
#  bfl::verify_arg_count "$#" 0 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_FIND} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency find not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  find -L "${@:-.}" -type l -exec ls -lond '{}' \;
  }
