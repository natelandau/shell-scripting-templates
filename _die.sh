#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::die().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints error message to stderr and exits with status code 1.
#
# @param string $msg (optional)
#   The error message.
#
# @example
#   bfl::error "Error: the foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::die() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 0 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare -r msg="${1:-"Error: unspecified error."}"

  # Declare all other variables (sorted by name).
  declare stack

  # Build a string showing the "stack" of functions that got us here.
  stack="${FUNCNAME[*]}"
  stack="${stack// / <- }"

  # Print the message.
  printf "%b\\n" "${red}${msg}${reset}"

  # Print the stack.
  printf "%b\\n" "${yellow}[${stack}]${reset}"

  exit 1
}
