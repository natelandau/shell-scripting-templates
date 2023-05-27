#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of useful utility functions
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::compare_pkg_versions().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Compares two strings containing version numbers.
#
# @param string $VERSION1
#   String with the first version number.
#
# @param string $VERSION2
#   String with the second version number.
#
# @return Integer $result
#   0  If VERSION1 is lower than VERSION2
#   1  If VERSION1 is equal to VERSION2
#   2  If VERSION1 is higher than VERSION2
#
# @example
#   bfl::compare_pkg_versions "1.0.0-SNAPSHOT" "1.2-dfsg"
#------------------------------------------------------------------------------
#
bfl::compare_pkg_versions() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  local -r VERSION1="${1:-}"; shift
  local -r VERSION2="${1:-}"; shift

  # VERSION1 is equal VERSION2
  [[ "${VERSION1}" == "${VERSION2}" ]] && return 1

  # VERSION1 is higher (or equal, but we already checked that) than VERSION2. If not that, it must be lower
  [[ "$( tr ' ' '\n' <<< "${VERSION1} ${VERSION2}" | sort --version-sort --reverse | head -n 1 )" == "${VERSION1}" ]] && return 2 || return 0
}
