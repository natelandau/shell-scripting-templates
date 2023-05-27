#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::warn().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints a warning message to stderr.
#
# The message provided will be prepended with "Warning. "
#
# @param string $msg (optional)
#   The message.
#
# @example
#   bfl::warn "The foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::warn() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 0 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare msg="${1:-"Unspecified warning."}"

  # Print the message.
  printf "%b\\n" "${bfl_aes_yellow}Warning. ${msg}${bfl_aes_reset}" 1>&2
}
