#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::pause_script().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Pause a script at any point and continue after user input.
#
# @param String $str (optional)
#   String for customized message.
#
# @param Integer $code (optional)
#   Code of interrupted exit.
#
# @example
#   if bfl::pause_script "Waiting for ...."
#------------------------------------------------------------------------------
bfl::pause_script() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _pauseMessage
  _pauseMessage="${1:-Paused. Ready to continue?}"

  if bfl::wait_confirmation "${_pauseMessage}"; then
      info "Continuing..."
      return 0
  fi

  bfl::writelog_info "Exiting Script"
  return ${2:-0}
  }
