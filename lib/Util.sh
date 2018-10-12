#!/usr/bin/env bash

# Library of useful utility functions
#
# @author  Michael Strache


# Prevent this library from being sourced more than once
[[ ${_GUARD_BFL_UTIL:-} -eq 1 ]] && return 0 || declare -r _GUARD_BFL_UTIL=1


# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #


# **************************************************************************** #
# Main                                                                         #
# **************************************************************************** #

# Compares two strings containing version numbers
#
# @param String   VERSION1        String with the first version number
# @param String   VERSION2        String with the second version number
#
# @return  Integer  0  If VERSION1 is lower than VERSION2
#                   1  If VERSION1 is equal to VERSION2
#                   2  If VERSION1 is higher than VERSION2
function Util::compare_versions() {
  local -r VERSION1="${1:-}"; shift
  local -r VERSION2="${1:-}"; shift

  # VERSION1 is equal VERSION2
  [[ "${VERSION1}" == "${VERSION2}" ]] && return 1

  # VERSION1 is higher (or equal, but we already checked that) than VERSION2. If not that, it must be lower
  [[ "$( tr ' ' '\n' <<< "${VERSION1} ${VERSION2}" | sort --version-sort --reverse | head -n 1 )" == "${VERSION1}" ]] && return 2 || return 0
}
