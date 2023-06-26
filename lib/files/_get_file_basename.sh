#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to manipulations with files
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::get_file_basename().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the file name, excluding extension. Don't mix with  basename !
#
# @param String $path
#   A relative path, absolute path, or symbolic link.
#
# @return String $file_name_without_extension
#   The file name, excluding extension.
#
# @example
#   bfl::get_file_basename "some/path/to/file.txt" --> "file"
#------------------------------------------------------------------------------
bfl::get_file_basename() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local ext
  ext=$(bfl::get_file_extension "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: ext=\$(bfl::get_file_extension $1)"; return 1; }
  echo ${1:0:-${#ext}-1}

  return 0
  }
