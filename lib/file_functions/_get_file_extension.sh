#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare file_name
  declare file_extension

  if bfl::is_empty "${path}"; then
    bfl::die "The path was not specified."
  fi

  file_name="$(bfl::get_file_name "$1")" || bfl::die
  file_extension="${file_name##*.}"

  printf "%s" "${file_extension}"
}
