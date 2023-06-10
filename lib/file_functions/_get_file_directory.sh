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
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "The path was not specified."

  local canonical_directory_path canonical_file_path

  # Verify that the path exists.
  canonical_file_path=$(bfl::get_file_path "$1") || bfl::die
  canonical_directory_path=$(dirname "$canonical_file_path") || bfl::die

  printf "%s" "$canonical_directory_path"
  return 0
  }
