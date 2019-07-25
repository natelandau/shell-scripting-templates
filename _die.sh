#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::die().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints message to stderr and exits with status code 1.
#
# @param string $message (optional)
#   Message to be printed.
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
lib::die() {
  declare error_msg="${1:-"Error: die() was called; error message not provided."}"
  declare stack

  # Validate argument count.
  if [[ "$#" -gt "1" ]]; then
    error_msg="Error: invalid number of arguments. Expected 0 or 1, received $#."
  fi

  # Build a string showing the "stack" of functions that got us here.
  stack="${FUNCNAME[*]}"
  stack="${stack// / <- }"
  echo -e "${red}${error_msg}\\n${yellow}[${stack}]${reset}" >&2
  exit 1
}
