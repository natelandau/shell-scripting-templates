#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to directories manipulation
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::get_directory_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the canonical path to a directory.
#
# @param String $path
#   A relative path, absolute path, or symbolic link.
#
# @return String $canonical_directory_path
#   The canonical path to the directory.
#
# @example
#   bfl::get_directory_path "./foo"
#------------------------------------------------------------------------------
bfl::get_directory_path() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: The path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  # Verify that the path exists.
  local canonical_directory_path
  canonical_directory_path=$(readlink -e "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' does not exist."; return 1; }

  # Verify that the path points to a directory, not a file.
  [[ -d "${canonical_directory_path}" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: '${canonical_directory_path}' is not a directory."; return 1; }

  printf "%s" "${canonical_directory_path}"
  return 0
  }
