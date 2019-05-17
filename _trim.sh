#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::trim().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Removes leading and trailing whitespace from a string.
#
# @param string $input
#   The string to be trimmed.
#
# @return string $output
#   The trimmed string.
#------------------------------------------------------------------------------
lib::trim() {
  lib::validate_arg_count "$#" 1 1 || return 1
  declare -r input="$1"
  declare temp="${input}"
  declare output

  # Trim leading whitespace characters.
  temp="${temp#"${temp%%[![:space:]]*}"}"
  # Trim trailing whitespace characters.
  temp="${temp%"${temp##*[![:space:]]}"}"

  output="${temp}"
  printf "%s" "${output}"
}
