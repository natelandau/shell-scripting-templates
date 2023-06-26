#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::command_exists().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks if a binary exists in the search PATH.
#
# @param String $cmd_name
#   Name of the binary to check for existence.
#
# @return boolean $result
#     0 / 1   ( true / false )
#
# @example
#   (bfl::command_exists ffmpeg ) && [SUCCESS] || [FAILURE]
#------------------------------------------------------------------------------
bfl::command_exists() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  if command -v "$1" >/dev/null 2>&1; then
      return 0
  fi

  bfl::writelog_debug "Did not find command: '$1'"
  return 1
  }
