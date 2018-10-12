#!/usr/bin/env bash

# Library of functions related to the Secure Shell
#
# @author  Michael Strache


# Prevent this library from being sourced more than once
[[ ${_GUARD_BFL_SSH:-} -eq 1 ]] && return 0 || declare -r _GUARD_BFL_SSH=1


# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #


# **************************************************************************** #
# Main                                                                         #
# **************************************************************************** #

# Checks if FILE exists on HOST and is readable
#
# @param String   FILE
# @param String   HOST
function Ssh::file_exists() {
  local -r FILE="${1:-}"; shift
  local -r HOST="${1:-}"; shift

  ssh -q -T "${HOST}" 'bash' <<-EOF
    [[ -r "${FILE}" ]] || exit 1
	EOF
}
