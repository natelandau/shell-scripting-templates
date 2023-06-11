#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::command_exists().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Check if a binary exists in the search PATH.
#
# @param String $cmd_name
#   Name of the binary to check for existence.
#
# @return boolean $result
#        0 / 1 (true / false)
#
# @example
#   (bfl::command_exists ffmpeg ) && [SUCCESS] || [FAILURE]
#------------------------------------------------------------------------------
#
bfl::command_exists() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  if command -v "$1" >/dev/null 2>&1; then
      return 0
  fi

  bfl::writelog_debug "Did not find dependency: '$1'"
  return 1
  }