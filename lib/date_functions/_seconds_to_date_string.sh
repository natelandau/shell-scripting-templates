#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions to help work with dates and time
#
# @file
# Defines function: bfl::seconds_to_date_string().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Convert seconds to HH:MM:SS.
#
# @param Integer $seconds
#   Time in seconds.
#
# @return String $result
#   HH:MM:SS.
#
# @example
#   bfl::seconds_to_date_string "SECONDS"
#   To compute the time it takes a script to run:
#      STARTTIME=$(date +"%s")
#             ...
#      ENDTIME=$(date +"%s")
#      TOTALTIME=$(($ENDTIME-$STARTTIME)) # human readable time
#      bfl::seconds_to_date_string "$TOTALTIME"
#------------------------------------------------------------------------------
#
bfl::seconds_to_date_string() {
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.

  local -i h m s

  ((h = $1 / 3600))
  ((m = ($1 % 3600) / 60))
  ((s = $1 % 60))
  printf "%02d:%02d:%02d\n" "$h" "$m" "$s"

  return 0
  }
