#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare canonical_file_path

  if bfl::is_empty "${path}"; then
    bfl::die "The path was not specified."
  fi

  # Verify that the path exists.
  if ! canonical_file_path=$(readlink -e "${path}"); then
    bfl::die "${path} does not exist."
  fi

  # Verify that the path points to a file, not a directory.
  if [[ ! -f "${canonical_file_path}" ]]; then
    bfl::die "${canonical_file_path} is not a file."
  fi

  printf "%s" "${canonical_file_path}"
}
