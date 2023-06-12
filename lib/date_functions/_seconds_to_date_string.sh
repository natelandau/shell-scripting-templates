#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ----------- https://github.com/jmooring/bash-function-library.git -----------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions to help work with dates and time
#
# @file
# Defines function: bfl::seconds_to_date_string().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Converts seconds to the hh:mm:ss format.
#
# @param Integer $seconds
#   The number of seconds to convert.
#
# @return String $hhmmss
#   The number of seconds in hh:mm:ss format.
#
# @example
#   bfl::seconds_to_date_string "3661"
#
#   To compute the time it takes a script to run:
#      STARTTIME=$(date +"%s")
#             ...
#      ENDTIME=$(date +"%s")
#      TOTALTIME=$(($ENDTIME-$STARTTIME)) # human readable time
#      bfl::seconds_to_date_string "$TOTALTIME"
#------------------------------------------------------------------------------
#
bfl::seconds_to_date_string() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  declare -ir seconds="$1"
  bfl::is_positive_integer "$seconds" || { bfl::writelog_fail "${FUNCNAME[0]} '$1' expected to be positive integer."; return 1; }

  declare hhmmss
  hhmmss=$(printf '%02d:%02d:%02d\n' $((seconds/3600)) $((seconds%3600/60)) $((seconds%60))) \
    || { bfl::writelog_fail "${FUNCNAME[0]} unable to convert $seconds to hh:mm:ss format."; return 1; }

  printf "%s" "$hhmmss"
  return 0
  }
