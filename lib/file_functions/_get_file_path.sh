#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_file_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the canonical path to a file.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $canonical_file_path
#   The canonical path to the file.
#
# @example
#   bfl::get_file_path "./foo/bar.text"
#------------------------------------------------------------------------------
bfl::get_file_path() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "The path was not specified."

  local canonical_file_path

  # Verify that the path exists.
  canonical_file_path=$(readlink -e "$1") || bfl::die "$1 does not exist."

  # Verify that the path points to a file, not a directory.
  ! [[ -f "$canonical_file_path" ]] && bfl::die "$canonical_file_path is not a file."

  printf "%s" "$canonical_file_path"
  return 0
  }
