#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
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
# Simple function to check if a given URL is available (e.g. before downloading a remote file).
#
# See <https://tools.ietf.org/html/rfc3986#section-2.1>.
#
# @param string $URL
#   URL of the file that should be checked.
#
# @param string $USR (optional)
#   Username to be used for authentication.
#
# @param string $PWD (optional)
#   Password to be used for authentication.
#
# @return boolean $exists
#        0 / 1 (true/false)
#
# @example
#   bfl::url_exists "https://google.com"
#------------------------------------------------------------------------------
bfl::url_exists() {
  bfl::verify_arg_count "$#" 1 3 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [1, 3]"  # Verify argument count.

  local -r URL="${1-}"
  local -r USR="${2-}"
  local -r PWD="${3-}"

  if which wget; then
      [[ ! -z "$USR" ]] && [[ ! -z "$PWD" ]] && local -r credentials="--user=$USR --password=$PWD"

      if wget "$credentials" --server-response --spider "$URL" 2>&1 | grep 'HTTP/1.1 200 OK'; then
          return 0
      fi
  else
      [[ ! -z "$USR" ]] && [[ ! -z "$PWD" ]] && local -r credentials="--user $USR:$PWD"

      if curl ${credentials} --output /dev/null --silent --head --fail "$URL"; then
          return 0
      fi
  fi

  return 1
  }
