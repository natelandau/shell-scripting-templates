#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare file_name
  declare file_name_without_extension

  if bfl::is_empty "${path}"; then
    bfl::die "The path was not specified."
  fi

  file_name="$(bfl::get_file_name "$1")" || bfl::die
  file_name_without_extension="${file_name%.*}"

  printf "%s" "${file_name_without_extension}"
}
