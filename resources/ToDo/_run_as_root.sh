#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# --------------- https://github.com/ralish/bash-script-template --------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions to help work with dates and time
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::run_as_root().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Run the requested command as root (via sudo if requested).
#
# @param String $Line_No  (Optional)
#   Set to zero to not attempt execution via sudo.
#
# @param String   $@
#   Passed through for execution as root user.
#
# @return Boolean $result
#   0 / 1   true / false
#
# @example
#   bfl::run_as_root .....
#------------------------------------------------------------------------------
bfl::run_as_root() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return 1; }   # Verify argument count.

  local _skip_sudo=false

  if [[ ${1} =~ ^0$ ]]; then
      _skip_sudo=true
      shift
  fi

  if [[ ${EUID} -eq 0 ]]; then
      "$@"
  elif ! ${_skip_sudo}; then
      sudo -H -- "$@"
  else
      bfl::writelog_fail "${FUNCNAME[0]}: Failed to run requested command as root: $*"
      return 1
  fi

  return 0
  }
