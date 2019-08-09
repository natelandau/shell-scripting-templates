#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::time_convert_s_to_hhmmss().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Converts seconds to the hh:mm:ss format.
#
# @param integer $seconds
#   The number of seconds to convert.
#   Example: 3661
#
# @return string $hhmmss
#   The number of seconds in hh:mm:ss format.
#   Example: 01h:01m:01s
#------------------------------------------------------------------------------
bfl::time_convert_s_to_hhmmss() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r seconds="$1"
  declare hhmmss

  if bfl::is_empty "${seconds}"; then
    bfl::die "Error: expected an integer, received an empty string."
  fi

  if ! bfl::is_integer "${seconds}"; then
    bfl::die "Error: expected an integer, received ${seconds}."
  fi

  hhmmss=$(printf '%02dh:%02dm:%02ds\n' \
    $((seconds/3600)) \
    $((seconds%3600/60)) \
    $((seconds%60))) \
    || bfl::die "Error: unable to convert ${seconds} to hh:mm:ss format."

  printf "%s" "${hhmmss}"
}
