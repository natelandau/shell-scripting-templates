#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
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
  local -r URL="${1-}"; shift
  local -r USR="${1-}"; shift
  local -r PWD="${1-}"; shift

  if which -s wget; then
      [[ ! -z ${USR} ]] && [[ ! -z ${PWD} ]] && local -r credentials="--user=${USR} --password=${PWD}"

      if wget ${credentials} --server-response --spider ${URL} 2>&1 | grep 'HTTP/1.1 200 OK'; then
          return 0
      fi
  else
      [[ ! -z ${USR} ]] && [[ ! -z ${PWD} ]] && local -r credentials="--user ${USR}:${PWD}"

      if curl ${credentials} --output /dev/null --silent --head --fail "${URL}"; then
         return 0
      fi
  fi

  return 1
}
