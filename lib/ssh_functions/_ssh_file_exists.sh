#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the Secure Shell
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::ssh_file_exists().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks if FILE exists on HOST and is readable.
#
# @param string $FILE
#   URL of the file that should be checked.
#
# @param string $HOST
#   Username to be used for authentication.
#
# @return boolean $exists
#        0 / 1 (true/false)
#
# @example
#   bfl::_ssh_file_exists "url" "host"
#------------------------------------------------------------------------------
bfl::ssh_file_exists() {
  local -r FILE="${1:-}"; shift
  local -r HOST="${1:-}"; shift

  ssh -q -T "${HOST}" 'bash' <<-EOF
      [[ -r "${FILE}" ]] || exit 1
	EOF

}
