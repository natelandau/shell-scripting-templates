#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# Library of functions related to terminal and file logging
# Inspired by https://github.com/gentoo/gentoo-functions/blob/master/functions.sh
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::write_log().
#------------------------------------------------------------------------------


# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #


# **************************************************************************** #
# Main                                                                         #
# **************************************************************************** #

# *************************************************************************** #
# Colors and formatting                                                       #
#                                                                             #
# The colors defined here are based on the Gentoo Linux color mappings        #
# -> https://wiki.gentoo.org/wiki//etc/portage/color.map                      #
#                                                                             #
# *************************************************************************** #
# Logging                                                                     #
# *************************************************************************** #

# Define the available log levels
readonly LOG_LVL_OFF=0
readonly LOG_LVL_ERR=1
readonly LOG_LVL_WRN=2
readonly LOG_LVL_INF=3
readonly LOG_LVL_DBG=4

# Define custom exception types
readonly ERR_BAD=100
readonly ERR_WORSE=101
readonly ERR_CRITICAL=102

# Set defaults
LOG_LEVEL=${LOG_LVL_INF}
LOG_SHOW_TIMESTAMP=false
LOG_FILE=/dev/null

#------------------------------------------------------------------------------
# @function
# Prints the passed message depending on its log-level to stdout.
#
# @param Integer $LEVEL
#   Log level of the message.
#
# @param String $MESSAGE
#   Message to log.
#
# @param String $STATUS
#   Short status string, that will be displayed right aligned in the log line.
#
# @example
#   bfl::write_log 0 "Compiling source" "Start operation"
#------------------------------------------------------------------------------
#
function write_log() {
  bfl::verify_arg_count "$#" 3 3 || exit 1  # Verify argument count.

  local -r LEVEL=${1:-$LOG_LVL_DBG}
  local msg="${2:-}"
  local -r STATUS=${3:-}

  ! [[ "$LOG_LEVEL" -ge "$LEVEL" ]] && return 1   #  maybe bfl::die ???
  [[ $LOG_SHOW_TIMESTAMP = true ]] && msg="$(date) - $msg"

  # To display a right aligned status we have to take some extra efforts
  [[ -z "$STATUS" ]] && echo "$msg" && return 0

  # Filter formatting sequences from the STATUS string to get its displayed length
  # https://stackoverflow.com/a/52781213/10495078
  local -r STATUS_filtered="$( sed -E -e "s/\x1B(\[[0-9;]*[JKmsu]|\(B)//g" <<< "$STATUS" )"
  local msg_width
  let msg_width=$(tput cols)-${#STATUS_filtered}

  printf "\r%-*s%s\n" $msg_width "$msg" "$STATUS"

  return 0
  }
