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
# Defines function: bfl::sleep().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Sleep for a specified amount of time.
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
# @return $value
#   0. Prints the message at each increment.
#
# @example
#   if bfl::sleep 10 1 "Waiting for cache to invalidate"
#------------------------------------------------------------------------------
bfl::sleep() {
  bfl::verify_arg_count "$#" 0 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 3]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -i i j
  local n=${1:-10}
  local sleepTime=${2:-1}
  local msg="${3:-...}"
# [[ $n =~ [.] ]] &&
  n=${n//.*/}  # cut floating point!
  ((n++))

  for ((i=1; i < n; i++)); do
      ((j=n-i))
#      if declare -f "bfl::writelog_info" &>/dev/null 2>&1; then
#          bfl::writelog_info "$msg $j"
#      else
          echo "$msg $j"
#      fi
      sleep "$sleepTime"
  done

  return 0
  }
