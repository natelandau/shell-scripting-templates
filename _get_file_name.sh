#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::get_file_name().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the file name, including extension.
#
# @param string $path
#   A relative path, absolute path, or symlink.
#
# @return string $file_name
#   The file name, including extension.
#------------------------------------------------------------------------------
lib::get_file_name() {
  lib::validate_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare canonical_file_path
  declare file_name

  if lib::is_empty "${path}"; then
    lib::die "Error: the path was not specified."
  fi

  canonical_file_path=$(lib::get_file_path "${path}") || lib::die
  file_name=$(basename "${canonical_file_path}") || lib::die

  printf "%s" "${file_name}"
}
