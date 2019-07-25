#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::get_file_name_without_extension().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the file name, excluding extension.
#
# @param string $path
#   A relative path, absolute path, or symlink.
#
# @return string $file_name_without_extension
#   The file name, excluding extension.
#------------------------------------------------------------------------------
lib::get_file_name_without_extension() {
  lib::validate_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare file_name
  declare file_name_without_extension

  if lib::is_empty "${path}"; then
    lib::die "Error: the path was not specified."
  fi

  file_name="$(lib::get_file_name "$1")" || lib::die
  file_name_without_extension="${file_name%.*}"

  printf "%s" "${file_name_without_extension}"
}
