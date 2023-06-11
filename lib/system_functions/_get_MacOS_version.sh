#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::get_MacOS_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Detects the host's version of MacOS.
#
# @return String   $result
#			0 - Success
#			1 - Can not find macOS version number or not on a mac
#     Prints the version number of macOS (ex: 11.6.1)
#
# @example
#   bfl::get_MacOS_version
#------------------------------------------------------------------------------
bfl::get_MacOS_version() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return 1; } # Verify argument count.

  local os=$(bfl::get_OS) || { bfl::writelog_fail "${FUNCNAME[0]}: error os=\$(bfl::get_OS)"; return 1; }

  ! [[ "$os" == "mac" ]] && return 1

  local macVersion
  macVersion="$(sw_vers -productVersion)" || { bfl::writelog_fail "${FUNCNAME[0]}: error macVersion=\$(sw_vers -productVersion)"; return 1; }
  printf "%s" "$macVersion"

  return 0
  }
