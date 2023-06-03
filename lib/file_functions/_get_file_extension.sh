#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_file_extension().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the file extension.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $file_extension
#   The file extension, excluding the preceding period.
#
# @example
#   bfl::get_file_extension "./foo/bar.txt"
#------------------------------------------------------------------------------
bfl::get_file_extension() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "The path was not specified."

  local file_name file_extension
  file_name=$(bfl::get_file_name "$1") || bfl::die
  file_extension="${file_name##*.}"

  printf "%s" "$file_extension"
  return 0
  }
