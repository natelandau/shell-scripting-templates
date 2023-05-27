#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::urlencode().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Percent-encodes a URL.
#
# See <https://tools.ietf.org/html/rfc3986#section-2.1>.
#
# @param string $str
#   The string to be encoded.
#
# @return string $str_encoded
#   The encoded string.
#
# @example
#   bfl::urlencode "foo bar"
#------------------------------------------------------------------------------
bfl::urlencode() {
  # Verify argument count.
  bfl::verify_arg_count "$#" 1 1 || exit 1

  # Verify dependencies.
  bfl::verify_dependencies "jq"

  # Declare positional arguments (readonly, sorted by position).
  declare -r str="$1"

  # Declare return value.
  declare str_encoded

  # Verify argument values.
  bfl::is_empty "$str" && bfl::die "Empty string."

  # Build the return value.
  str_encoded=$(jq -Rr @uri <<< "${str}") \
    || bfl::die "Unable to URL encode the string."

  # Print the return value.
  printf "%s\\n" "${str_encoded}"
}
