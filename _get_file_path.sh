#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::get_file_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the canonical path to a file.
#
# @param string $path
#   A relative path, absolute path, or symlink.
#
# @return string $canonical_file_path
#   The canonical path to the file.
#------------------------------------------------------------------------------
lib::get_file_path() {
  lib::validate_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare canonical_file_path

  if lib::is_empty "${path}"; then
    lib::die "Error: the path was not specified."
  fi

  # Verify that the path exists.
  if ! canonical_file_path=$(readlink -e "${path}"); then
    lib::die "Error: ${path} does not exist."
  fi

  # Verify that the path points to a file, not a directory.
  if [[ ! -f "${canonical_file_path}" ]]; then
    lib::die "Error: ${canonical_file_path} is not a file."
  fi

  printf "%s" "${canonical_file_path}"
}
