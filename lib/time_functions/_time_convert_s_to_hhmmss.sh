#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::time_convert_s_to_hhmmss().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Converts seconds to the hh:mm:ss format.
#
# @param int $seconds
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

  bfl::is_positive_integer "${seconds}" \
    || bfl::die "Expected positive integer, received ${seconds}."

  hhmmss=$(printf '%02d:%02d:%02d\n' \
    $((seconds/3600)) \
    $((seconds%3600/60)) \
    $((seconds%60))) \
    || bfl::die "Unable to convert ${seconds} to hh:mm:ss format."

  printf "%s" "${hhmmss}"
}
