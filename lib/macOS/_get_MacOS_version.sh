#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions for use on computers running MacOS
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::MacOS::get_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Detects the host's version of MacOS.
#
# @return String   $result
#			0 - Success
#			1 - Can not find macOS version number or not on a mac
#     Prints the version number of macOS (ex: 11.6.1)
#
# @example
#   bfl::MacOS::get_version
#------------------------------------------------------------------------------
bfl::MacOS::get_version() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local os
  os=$(bfl::get_OS) || { bfl::writelog_fail "${FUNCNAME[0]}: error os=\$(bfl::get_OS)"; return 1; }
  [[ "$os" == "mac" ]] || return 1

  local macVersion
  macVersion="$(sw_vers -productVersion)" || { bfl::writelog_fail "${FUNCNAME[0]}: error macVersion=\$(sw_vers -productVersion)"; return 1; }
  printf "%s" "$macVersion"

  return 0
  }
