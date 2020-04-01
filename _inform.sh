#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::inform().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints a informational message to stderr.
#
# @param string $msg
#   The message.
#
# @example
#   bfl::inform "The foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::inform() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare msg="${1}"

  # Verify argument values.
  bfl::is_blank "$msg" && bfl::die "A message was not specified."

  # Print the message.
  printf "%b\\n" "${msg}" 1>&2
}
