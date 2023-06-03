#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
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
  local -r FILE="${1:-}"
  local -r HOST="${2:-}"

  ssh -q -T "${HOST}" 'bash' <<-EOF
      [[ -r "${FILE}" ]] || exit 1
	EOF

  }
