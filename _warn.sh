#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::warn().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints warning message to stdout.
#
# @param string $msg
#   The warning message.
#
# @example
#   bfl::warn "Warning: the foo is bar."
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::warn() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 1 || exit 1

  # Declare positional arguments (readonly, sorted by position).
  declare msg="${1}"

  # Verify argument values.
  bfl::is_blank "$msg" && bfl::die "Error: warning message not specified."

  # Print the message.
  printf "%b\\n" "${yellow}${msg}${reset}"
}
