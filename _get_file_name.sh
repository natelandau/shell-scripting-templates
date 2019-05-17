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
  lib::validate_arg_count "$#" 1 1 || return 1
  declare -r path="$1"
  declare canonical_file_path
  declare file_name

  if lib::is_empty "${path}"; then
    lib::err "Error: the path was not specified."
    return 1
  fi

  canonical_file_path=$(lib::get_file_path "${path}") || return 1
  file_name=$(basename "${canonical_file_path}")

  printf "%s" "${file_name}"
}
