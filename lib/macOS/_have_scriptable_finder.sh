#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions for use on computers running MacOS
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::MacOS::have_scriptable_finder().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Determine on MacOS whether we can script the Finder or not.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::MacOS::have_scriptable_finder
#------------------------------------------------------------------------------
bfl::MacOS::have_scriptable_finder() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local os=$(bfl::get_OS) || { bfl::writelog_fail "${FUNCNAME[0]}: error os=\$(bfl::get_OS)"; return 1; }
  [[ "$os" == "mac" ]] || return 1

  local _finder_pid
  _finder_pid="$(pgrep -f /System/Library/CoreServices/Finder.app | head -n 1)"

  if [[ (${_finder_pid} -gt 1) && (${STY-} == "") ]]; then
      return 0
  fi

  return 1
  }
