#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::trim().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Removes leading and trailing whitespace, including blank lines, from string.
#
# The string can either be single or multi-line.
#
# @param string $input
#   The string to be trimmed.
#
# @return string $output
#   The trimmed string.
#------------------------------------------------------------------------------
bfl::trim() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r input="$1"
  declare output

  # Explanation of sed commands:
  # - Remove leading whitespace from every line: s/^[[:space:]]+//
  # - Remove trailing whitespace from every line: s/^[[:space:]]+//
  # - Remove leading and trailing blank lines: /./,$ !d
  #
  # See https://tinyurl.com/yav7zw9k and https://tinyurl.com/3z8eh

  output=$(printfS "%b" "${input}" | \
    sed -E 's/^[[:space:]]+// ; s/[[:space:]]+$// ; /./,$ !d') \
    || bfl::die "Error: unable to trim whitespace."

  printf "%s" "${output}"
}
