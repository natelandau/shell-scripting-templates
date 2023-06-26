#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to manipulations with files
#
# @authors  Joe Mooring
#
# @file
# Defines function: bfl::get_file_name().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the file name, including extension.
#
# @param String $path
#   A relative path, absolute path, or symbolic link.
#
# @return String $file_name
#   The file name, including extension.
#
# @example
#   bfl::get_file_name "./foo/bar.text"
#------------------------------------------------------------------------------
bfl::get_file_name() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }

#  local canonical_file_path file_name
#  canonical_file_path=$(bfl::get_file_path "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: canonical_file_path=\$(bfl::get_file_path $1)"; return 1; }
  file_name="${1##*/}"   # $(basename "${canonical_file_path}")

  printf "%s" "${file_name}"
  return 0
  }
