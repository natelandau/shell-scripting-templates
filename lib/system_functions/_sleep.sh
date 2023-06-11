#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions to help work with dates and time
#
# @file
# Defines function: bfl::sleep().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Sleep for a specified amount of time.
#
# @param Integer $seconds (optional)
#   Total seconds to sleep for. Default = 10.
#
# @param Integer $step (optional)
#   Increment to count down.
#
# @param String $msg (optional)
#   Message to print at each increment. Default is ...
#
# @return Boolean   $value
#   0 / 1   (true / false)
#   Prints the message at each increment.
#
# @example
#   if bfl::sleep 10 1 "Waiting for cache to invalidate"
#------------------------------------------------------------------------------
#
bfl::sleep() {
  bfl::verify_arg_count "$#" 1 1 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1" && return 1 # Verify argument count.

  local i j t
  local n=${1:-10}
  local sleepTime=${2:-1}
  local msg="${3:-...}"
  ((t=n+1))

  for ((i=1; i <= n; i++)); do
      ((j = t - i))
#      if declare -f "bfl::writelog_info" &>/dev/null 2>&1; then
#          bfl::writelog_info "$msg $j"
#      else
          echo "$msg $j"
#      fi
      sleep "$sleepTime"
  done

  return 0
  }
