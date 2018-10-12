#!/usr/bin/env bash

# Library of functions related to the internet
#
# @author  Michael Strache


# Simple function to check if a given URL is available (e.g. before downloading a remote file)
#
# @param String   URL             URL of the file that should be checked
# @param String   USR             Username to be used for authentication (optional)
# @param String   PWD             Password to be used for authentication (optional)
#
# @return Boolean  true if URL can be accessed, otherwise false
function Http::Url::exists() {
  local -r URL="${1-}"; shift
  local -r USR="${1-}"; shift
  local -r PWD="${1-}"; shift

  if which -s wget; then
    [ ! -z ${USR} ] && [ ! -z ${PWD} ] && local -r credentials="--user=${USR} --password=${PWD}"

    if wget ${credentials} --server-response --spider ${URL} 2>&1 | grep 'HTTP/1.1 200 OK'; then
      return 0
    fi
  else
    [ ! -z ${USR} ] && [ ! -z ${PWD} ] && local -r credentials="--user ${USR}:${PWD}"

    if curl ${credentials} --output /dev/null --silent --head --fail "${URL}"; then
     return 0
    fi
  fi

  return 1
}
