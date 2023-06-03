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

#
# Clean up before setting anything
#

# Initialize RC_NOCOLOR if it is unset. Set it to 'yes' if you do not want colors to be used
RC_NOCOLOR=${RC_NOCOLOR:-no}

# Reset all colors
unset CLR_GOOD CLR_INFORM CLR_WARN CLR_BAD CLR_HILITE CLR_BRACKET CLR_NORMAL

# Reset all formatting options
unset FMT_BOLD FMT_UNDERLINE


#
# Setup the colors depending on what the terminal supports
#

# Only enable colors if it is wanted
if ! [[ "${RC_NOCOLOR}" =~ ^(YES|Yes|yes)$ ]]; then

    # If tput is present, prefer it over the escape sequence based formatting
    if ( command -v tput ) >/dev/null 2>&1; then
        # tput color table
        # -> http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html

        [[ $( tput colors ) -ge 256 ]] && _bfl_temporary_var=true || _bfl_temporary_var=false
        $_bfl_temporary_var && readonly CLR_GOOD="$(tput setaf 10)"     || readonly CLR_GOOD="$(tput bold)$(tput setaf 2)"     # Bright Green
        readonly CLR_INFORM="$(tput setaf 2)"                                                                                  # Green
        $_bfl_temporary_var && readonly CLR_WARN="$(tput setaf 11)"     || readonly CLR_WARN="$(tput bold)$(tput setaf 3)"     # Bright Yellow
        $_bfl_temporary_var && readonly CLR_BAD="$(tput setaf 9)"       || readonly CLR_BAD="$(tput bold)$(tput setaf 1)"      # Bright Red
        $_bfl_temporary_var && readonly CLR_HILITE="$(tput setaf 14)"   || readonly CLR_HILITE="$(tput bold)$(tput setaf 6)"   # Bright Cyan
        $_bfl_temporary_var && readonly CLR_BRACKET="$(tput setaf 12)"  || readonly CLR_BRACKET="$(tput bold)$(tput setaf 4)"  # Bright Blue
        readonly CLR_NORMAL="$(tput sgr0)"

        # Enable additional formatting for 256 color terminals (on 8 color terminals the formatting likely is implemented as a brighter color rather than a different font)
        $_bfl_temporary_var && readonly FMT_BOLD="$(tput bold)"
        $_bfl_temporary_var && readonly FMT_UNDERLINE="$(tput smul)"
    else
        # Escape sequence color table
        # -> https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

        [[ "${TERM}" =~ 256color ]] && _bfl_temporary_var=true || _bfl_temporary_var=false
        $_bfl_temporary_var && readonly CLR_GOOD="$(printf '\033[38;5;10m')"    || CLR_GOOD="$(printf '\033[32;01m')"
        $_bfl_temporary_var && readonly CLR_INFORM="$(printf '\033[38;5;2m')"   || CLR_INFORM="$(printf '\033[32m')"
        $_bfl_temporary_var && readonly CLR_WARN="$(printf '\033[38;5;11m')"    || CLR_WARN="$(printf '\033[33;01m')"
        $_bfl_temporary_var && readonly CLR_BAD="$(printf '\033[38;5;9m')"      || CLR_BAD="$(printf '\033[31;01m')"
        $_bfl_temporary_var && readonly CLR_HILITE="$(printf '\033[38;5;14m')"  || CLR_HILITE="$(printf '\033[36;01m')"
        $_bfl_temporary_var && readonly CLR_BRACKET="$(printf '\033[38;5;12m')" || CLR_BRACKET="$(printf '\033[34;01m')"
        readonly CLR_NORMAL="$(printf '\033[0m')"

        # Enable additional formatting for 256 color terminals (on 8 color terminals the formatting likely is implemented as a brighter color rather than a different font)
        $_bfl_temporary_var && readonly FMT_BOLD="$(printf '\033[01m')"
        $_bfl_temporary_var && readonly FMT_UNDERLINE="$(printf '\033[04m')"
    fi
fi

# *************************************************************************** #
# Logging                                                                     #
# *************************************************************************** #

# Define the available log levels
readonly LOG_LVL_OFF=0
readonly LOG_LVL_ERR=1
readonly LOG_LVL_WRN=2
readonly LOG_LVL_INF=3
readonly LOG_LVL_DBG=4

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
