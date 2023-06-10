#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_file_name().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the file name, including extension.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $file_name
#   The file name, including extension.
#
# @example
#   bfl::get_file_name "./foo/bar.text"
#------------------------------------------------------------------------------
bfl::get_file_name() {
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "The path was not specified."

  local canonical_file_path file_name
  canonical_file_path=$(bfl::get_file_path "$1") || bfl::die
  file_name=$(basename "$canonical_file_path") || bfl::die

  printf "%s" "$file_name"
  return 0
  }
