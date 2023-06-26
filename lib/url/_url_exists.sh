#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the internet
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::url_exists().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Simple function to check if a given URL is available (e.g. before downloading a remote file).
#
# See <https://tools.ietf.org/html/rfc3986#section-2.1>.
#
# @param String $url
#   URL of the file that should be checked.
#
# @param String $user  (optional)
#   Username to be used for authentication.
#
# @param String $pass  (optional)
#   Password to be used for authentication.
#
# @return Boolean $exists
#      0 / 1   ( true / false )
#
# @example
#   bfl::url_exists "https://google.com"
#------------------------------------------------------------------------------
bfl::url_exists() {
  bfl::verify_arg_count "$#" 1 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 3]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r url="${1-}"
  local -r usr="${2-}"
  local -r pass="${3-}"

  if which wget; then
      [[ -n "$usr" && -n "$pass" ]] && local -r credentials="--user=$usr --password=$pass"

      if wget "$credentials" --server-response --spider "$url" 2>&1 | grep 'HTTP/1.1 200 OK'; then
          return 0
      fi
  else
      [[ -n "$usr" && -n "$pass" ]] && local -r credentials="--user $usr:$pass"

      if curl ${credentials} --output /dev/null --silent --head --fail "$url"; then
          return 0
      fi
  fi

  return 1
  }
