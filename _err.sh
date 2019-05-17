#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::err().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints message to stderr.
#
# @param string $message
#   Message to be printed.
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
lib::err() {
  lib::validate_arg_count "$#" 1 1 || return 1
  declare -r message="$1"
  declare stack

  if lib::is_empty "${message}"; then
    lib::err "Error: \$message is a an empty string."
    return 1
  fi

  # Build a string showing the "stack" of functions that got us here.
  # This will look like "function_c <- function_b <- function_a."
  stack=$(lib::implode " <- " "${FUNCNAME[@]:1}") || return 1
  echo -e "${red}${message} ${yellow}[${stack}]${reset}" >&2
}
