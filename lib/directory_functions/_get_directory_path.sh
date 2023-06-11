#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_directory_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the canonical path to a directory.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $canonical_directory_path
#   The canonical path to the directory.
#
# @example
#   bfl::get_directory_path "./foo"
#------------------------------------------------------------------------------
bfl::get_directory_path() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::writelog_fail "${FUNCNAME[0]}: The path was not specified." && return 1

  # Verify that the path exists.
  local canonical_directory_path
  canonical_directory_path=$(readlink -e "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' does not exist."; return 1; }

  # Verify that the path points to a directory, not a file.
  ! [[ -d "${canonical_directory_path}" ]] && bfl::writelog_fail "${FUNCNAME[0]}: '${canonical_directory_path}' is not a directory." && return 1

  printf "%s" "${canonical_directory_path}"
  return 0
  }