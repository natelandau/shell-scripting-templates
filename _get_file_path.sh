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
  lib::validate_arg_count "$#" 1 1 || return 1
  declare -r path="$1"
  declare canonical_file_path

  if lib::is_empty "${path}"; then
    lib::err "Error: the path was not specified."
    return 1
  fi

  # Verify that the path exists.
  if ! canonical_file_path=$(realpath -eq "${path}"); then
    lib::err "Error: ${path} does not exist."
    return 1
  fi

  # Verify that the path points to a file, not a directory.
  if [[ ! -f "${canonical_file_path}" ]]; then
    lib::err "Error: ${canonical_file_path} is not a file."
    return 1
  fi

  printf "%s" "${canonical_file_path}"
}
