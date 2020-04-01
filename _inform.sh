#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::inform().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints an informational message to stderr.
#
# @param string $msg (optional)
#   The message. A blank line will be printed if no message is provided.
#
# @example
#   bfl::inform "The foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::inform() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 0 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare msg="${1:-}"

  # Print the message.
  printf "%b\\n" "${msg}" 1>&2
}
