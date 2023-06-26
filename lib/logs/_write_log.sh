#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to terminal and file logging
# Inspired by https://github.com/gentoo/gentoo-functions/blob/master/functions.sh
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::write_log().
#------------------------------------------------------------------------------

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
readonly LOG_LVL_ERROR=1
readonly LOG_LVL_WARN=2
readonly LOG_LVL_INFORM=3
readonly LOG_LVL_DEBUG=4

# Define custom exception types
readonly ERR_BAD=100
readonly ERR_WORSE=101
readonly ERR_CRITICAL=102

# Set defaults
LOG_LEVEL=${LOG_LVL_INFORM}
LOG_SHOW_TIMESTAMP=false
LOG_FILE=/dev/null

#------------------------------------------------------------------------------
# @function
#   Prints the passed message depending on its log-level to stdout.
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
# @param String    LogFile (optional)
#   Log file.
#
# @example
#   bfl::write_log 0 "Compiling source" "Start operation" "$HOME/.faults"
#------------------------------------------------------------------------------
bfl::write_log() {
  bfl::verify_arg_count "$#" 3 4 || { # Нельзя bfl::die Verify argument count.
      [[ $BASH_INTERACTIVE == true ]] && printf "${FUNCNAME[0]}: error $*\n" > /dev/tty
      return 1
      }

  # Verify argument values.
  bfl::is_blank "$2" && { # Нельзя bfl::die Verify argument count.
      [[ $BASH_INTERACTIVE == true ]] && printf "${FUNCNAME[0]}: parameter 1 is blank!\n" > /dev/tty
      return 1
      }

  # Verify argument values.
  local -r logfile="${4:-$BASH_FUNCTION_LOG}"   # LOGFILE="$(pwd)/${0##*/}.log"   # $(basename "$0")
  local d="${logfile%/*}"  #  $(dirname "$logfile")
  [[ -d "$d" ]] || {
      mkdir -p "$d" || { # Нельзя bfl::die Verify arguments
      [[ $BASH_INTERACTIVE == true ]] && printf "${FUNCNAME[0]}: cannot create directory '$d'!\n" > /dev/tty
      return 1
      }
  }
  [[ -d "$d" ]] || { # Нельзя bfl::die Verify arguments
      [[ $BASH_INTERACTIVE == true ]] && printf "${FUNCNAME[0]}: directory '$d' doesn't exists!\n" > /dev/tty
      return 1
      }
  [[ -f "$logfile" ]] || {
      touch "$logfile" || { # Нельзя bfl::die Verify arguments
      [[ $BASH_INTERACTIVE == true ]] && printf "${FUNCNAME[0]}: cannot create '$logfile'!\n" > /dev/tty
      return 1
      }
  }
  [[ -f "$logfile" ]] || { # Нельзя bfl::die Verify arguments
      [[ $BASH_INTERACTIVE == true ]] && printf "${FUNCNAME[0]}: '$logfile' doesn't exists,no rights to create it!\n" > /dev/tty
      return 1
      }

  local -r LEVEL=${1:-$LOG_LVL_DEBUG}
#  ! [[ "$LOG_LEVEL" -ge "$LEVEL" ]] && { # Нельзя bfl::die Verify argument count.
#      [[ $BASH_INTERACTIVE == true ]] && printf "${FUNCNAME[0]}: error $*\n" > /dev/tty
#      return 1
#      }

  local msg="${2:-}"
  local -r STATUS=${3:-}
#  [[ -z "$STATUS" ]] && echo "$msg" && return 0   # To display a right aligned status we have to take some extra efforts

  # Don't use colors in logs https://stackoverflow.com/a/52781213/10495078

# или local -r msg_="$(printf "%s" "${_message}" | sed -E 's/(\x1b)?\[(([0-9]{1,2})(;[0-9]{1,3}){0,2})?[mGK]//g')"
  local -r msg_="$( sed -E -e "s/\x1B(\[[0-9;]*[JKmsu]|\(B)//g" <<< "$msg" )"
  local -r STATUS_="$( sed -E -e "s/\x1B(\[[0-9;]*[JKmsu]|\(B)//g" <<< "$STATUS" )"
  local msg_width
  let msg_width=$(tput cols)-${#STATUS_}

  [[ $LOG_SHOW_TIMESTAMP = true ]] && msg_="$(date '+%Y-%m-%d %H:%M:%S') $msg_"
  printf "\r%-*s%s\n" $msg_width "$msg_" "$STATUS_" >> "$logfile"

  return 0
  }
