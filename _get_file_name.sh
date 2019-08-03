#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::get_file_name().
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
bfl::get_file_name() {
  bfl::validate_arg_count "$#" 1 1 || exit 1

  declare -r path="$1"
  declare canonical_file_path
  declare file_name

  if bfl::is_empty "${path}"; then
    bfl::die "Error: the path was not specified."
  fi

  canonical_file_path=$(bfl::get_file_path "${path}") || bfl::die
  file_name=$(basename "${canonical_file_path}") || bfl::die

  printf "%s" "${file_name}"
}
