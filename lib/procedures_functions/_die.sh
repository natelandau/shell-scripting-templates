#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::die().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints a fatal error message to stderr, then exits with status code 1.
#
# The message provided will be prepended with "Fatal error. "
#
# @param string $msg (optional)
#   The message.
#
# @example
#   bfl::error "The foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::die() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 0 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare -r msg="${1:-"Unspecified fatal error."}"

  # Declare all other variables (sorted by name).
  declare stack

  # Build a string showing the "stack" of functions that got us here.
  stack="${FUNCNAME[*]}"
  stack="${stack// / <- }"

  # Print the message.
  printf "%b\\n" "${bfl_aes_red}Fatal error. ${msg}${bfl_aes_reset}" 1>&2

  # Print the stack.
  printf "%b\\n" "${bfl_aes_yellow}[${stack}]${bfl_aes_reset}" 1>&2

  exit 1
}
