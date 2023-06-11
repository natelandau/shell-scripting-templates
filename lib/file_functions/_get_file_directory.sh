#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_file_directory().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the canonical path to the directory in which a file resides.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $canonical_directory_path
#   The canonical path to the directory in which a file resides.
#
# @example
#   bfl::get_file_directory "./foo/bar.txt"
#------------------------------------------------------------------------------
bfl::get_file_directory() {
  bfl::verify_arg_count "$#" 1 1 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1" && return 1 # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && bfl::writelog_fail "${FUNCNAME[0]}: path was not specified." && return 1

  local canonical_directory_path canonical_file_path

  # Verify that the path exists.
  canonical_file_path=$(bfl::get_file_path "$1") || bfl::writelog_fail "${FUNCNAME[0]}: canonical_file_path=\$(bfl::get_file_path $1)" && return 1
  canonical_directory_path=$(dirname "${canonical_file_path}") || bfl::writelog_fail "${FUNCNAME[0]}: canonical_directory_path=\$(dirname ${canonical_file_path})" && return 1

  printf "%s" "${canonical_directory_path}"
  return 0
  }
