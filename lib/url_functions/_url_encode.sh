#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
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
  bfl::verify_arg_count "$#" 1 1 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1" && return 1     # Verify argument count.
  bfl::verify_dependencies "jq"  || bfl::writelog_fail "${FUNCNAME[0]}: dependency jq not found." && return 1  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && bfl::writelog_fail "${FUNCNAME[0]}: empty string." && return 1

  local rslt  # Build the return value.
  rslt=$(jq -Rr @uri <<< "$1") || bfl::writelog_fail "${FUNCNAME[0]}: unable to encode url $1." && return 1

  # Print the return value.
  printf "%s\\n" "$rslt"
  }
