#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::url_encode().
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
#   bfl::url_encode "foo bar"
#------------------------------------------------------------------------------
bfl::url_encode() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.
  bfl::verify_dependencies "jq"  # Verify dependencies.

  # Verify argument values.
  [[ -z "$1" ]] && bfl::die "Empty string."

  # Declare return value.
  local str_encoded

  # Build the return value.
  str_encoded=$(jq -Rr @uri <<< "$1") || bfl::die "Unable to URL encode the string."

  # Print the return value.
  printf "%s\\n" "${str_encoded}"
  }
