#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::warn().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints a warning message to stdout.
#
# The message provided will be prepended with "Warning. "
#
# @param string $msg
#   The warning message.
#
# @example
#   bfl::warn "The foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::warn() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare msg="${1}"

  # Verify argument values.
  bfl::is_blank "$msg" && bfl::die "A warning message was not specified."

  # Print the message.
  printf "%b\\n" "${bfl_aes_yellow}Warning. ${msg}${bfl_aes_reset}"
}
