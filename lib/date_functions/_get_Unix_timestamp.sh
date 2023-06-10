#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions to help work with dates and time
#
# @file
# Defines function: bfl::get_Unix_timestamp().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Get the current time in unix timestamp.
#
# @return boolean $result
#   Prints result ~ 1591554426.
#
# @example
#   bfl::get_Unix_timestamp
#------------------------------------------------------------------------------
#
bfl::get_Unix_timestamp() {
  bfl::verify_arg_count "$#" 0 0 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 0"  # Verify argument count.

  local _now
  _now="$(date --universal +%s)" || return 1
  printf "%s\n" "${_now}"

  return 0
  }
