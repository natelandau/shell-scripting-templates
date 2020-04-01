#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::error().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints an error message to stderr.
#
# The message provided will be prepended with "Error. "
#
# @param string $msg
#   The message.
#
# @example
#   bfl::error "The foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::error() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare msg="${1}"

  # Verify argument values.
  bfl::is_blank "$msg" && bfl::die "A message was not specified."

  # Print the message.
  printf "%b\\n" "${bfl_aes_red}Error. ${msg}${bfl_aes_reset}" 1>&2
}
