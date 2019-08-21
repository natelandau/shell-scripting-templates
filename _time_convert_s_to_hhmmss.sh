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
#
# @return string $hhmmss
#   The number of seconds in hh:mm:ss format.
#
# @example
#   bfl::time_convert_s_to_hhmmss "3661"
#------------------------------------------------------------------------------
bfl::time_convert_s_to_hhmmss() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r seconds="$1"
  declare hhmmss

  if bfl::is_empty "${seconds}"; then
    bfl::die "Expected an integer, received an empty string."
  fi

  if ! bfl::is_integer "${seconds}"; then
    bfl::die "Expected an integer, received ${seconds}."
  fi

  hhmmss=$(printf '%02d:%02d:%02d\n' \
    $((seconds/3600)) \
    $((seconds%3600/60)) \
    $((seconds%60))) \
    || bfl::die "Unable to convert ${seconds} to hh:mm:ss format."

  printf "%s" "${hhmmss}"
}
