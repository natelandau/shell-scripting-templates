#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare canonical_directory_path

  if bfl::is_empty "${path}"; then
    bfl::die "The path was not specified."
  fi

  # Verify that the path exists.
  if ! canonical_directory_path=$(readlink -e "${path}"); then
    bfl::die "${path} does not exist."
  fi

  # Verify that the path points to a directory, not a file.
  if [[ ! -d "${canonical_directory_path}" ]]; then
    bfl::die "${canonical_directory_path} is not a directory."
  fi

  printf "%s" "${canonical_directory_path}"
}
