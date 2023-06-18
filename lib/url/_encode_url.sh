#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to the internet
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::encode_url().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Percent-encodes a URL.
#
# See <https://tools.ietf.org/html/rfc3986#section-2.1>.
#
# @param String $str
#   The string to be encoded.
#
# @return String $str_encoded
#   The encoded string.
#
# @example
#   bfl::encode_url "foo bar"
#------------------------------------------------------------------------------
bfl::encode_url() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return $BFL_ErrCode_Not_verified_args_count; }     # Verify argument count.
  bfl::verify_dependencies "jq"  || { bfl::writelog_fail "${FUNCNAME[0]}: dependency jq not found."; return $BFL_ErrCode_Not_verified_dependency; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: empty string."; return $BFL_ErrCode_Not_verified_arg_values; }

  local rslt  # Build the return value.
  rslt=$(jq -Rr @uri <<< "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: unable to encode url $1."; return 1; }

  # Print the return value.
  printf "%s\\n" "$rslt"

# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#    for ((i = 0; i < ${#1}; i++)); do
#        if [[ ${1:i:1} =~ ^[a-zA-Z0-9\.\~_-]$ ]]; then
#            printf "%s" "${1:i:1}"
#        else
#            printf '%%%02X' "'${1:i:1}"
#        fi
#    done
  return 0
  }
