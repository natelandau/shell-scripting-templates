#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_file_name_without_extension().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the file name, excluding extension.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $file_name_without_extension
#   The file name, excluding extension.
#
# @example
#   bfl::get_file_name_without_extension "./foo/bar.txt"
#------------------------------------------------------------------------------
bfl::get_file_name_without_extension() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  [[ -z "$1" ]] && bfl::die "The path was not specified."

  local file_name file_name_without_extension

  file_name=$(bfl::get_file_name "$1") || bfl::die
  file_name_without_extension="${file_name%.*}"

  printf "%s" "$file_name_without_extension"
  return 0
  }
