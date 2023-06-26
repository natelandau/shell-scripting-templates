#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#[[ -n $FMT_UNDERLINE ]] && return 0
# https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
# ------------- https://github.com/jmooring/bash-function-library -------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to constants declarations
#
# @authors  Joe Mooring, Nathaniel Landau
#
# @file
# Defines and calls function: bfl::declare_terminal_colors().
#------------------------------------------------------------------------------

# Clean up before setting anything
#unset CLR_GOOD CLR_INFORM CLR_WARN CLR_BAD CLR_HILITE CLR_BRACKET CLR_NORMAL  # Reset all colors
#unset FMT_BOLD FMT_UNDERLINE                                                  # Reset all formatting options
#------------------------------------------------------------------------------
#
# Setup the colors depending on what the terminal supports
#
#------------------------------------------------------------------------------
# @function
#   Declares colors for terminal.
#
# -----------------------------------------------------------------------------
# @return global value  $TPUT_COLOR
#   color value
#
# @example:
#   bfl::declare_terminal_colors
#------------------------------------------------------------------------------
# shellcheck disable=SC2154
bfl::declare_terminal_colors() {
#  НЕЛЬЗЯ! В итог циклическая зависимость
#  [[ ${_BFL_HAS_TPUT} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'tput' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local clr="${RC_NOCOLOR:-no}"
  [[ "${clr,,}" =~ ^yes|true$ ]] && local -r bEnabled=false || local -r bEnabled=true
  local use256=false

  if ( command -v tput ) >/dev/null 2>&1; then
      local -r has_tput=true
  else
      local -r has_tput=false
  fi

  if $has_tput; then  # If tput is present, prefer it over the escape sequence based formatting
      [[ $( tput colors ) -ge 256 ]] >/dev/null 2>&1 && use256=true

      # tput color table   => http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
      declare -gr DarkGreen="$(tput setaf 2)"    # Вот как достигается яркость!
      $use256 && declare -gr Green="$(tput setaf 82)"                || declare -gr Green="$(tput bold)$DarkGreen"       # Bright Green

      declare -gr DarkYellow="$(tput setaf 3)"
      $use256 && declare -gr Yellow="$(tput bold)$(tput setaf 190)"  || declare -gr Yellow="$(tput bold)$DarkYellow"     # Bright Yellow

      declare -gr DarkRed="$(tput bold)$(tput setaf 1)"
      declare -gr PaleRed=$(tput setaf 9)
      $use256 && declare -gr Red="$(tput bold)$(tput setaf 196)"     || declare -gr Red="$DarkRed"                       # Bright Red

      declare -gr DarkCyan="$(tput bold)$(tput setaf 6)"
      $use256 && declare -gr Cyan="$(tput bold)$(tput setaf 14)"     || declare -gr Cyan="$DarkCyan"                     # Bright Cyan

      declare -gr DarkBlue="$(tput bold)$(tput setaf 4)"
      $use256 && declare -gr PaleBlue="$(tput bold)$(tput setaf 12)" || declare -gr PaleBlue="$DarkBlue"
      $use256 && declare -gr Blue="$(tput bold)$(tput setaf 27)"     || declare -gr Blue="$DarkBlue"                     # Bright Blue

      declare -gr DarkPurple="$(tput bold)$(tput setaf 13)"
      $use256 && declare -gr Purple="$(tput setaf 171)"              || declare -gr Purple="$DarkPurple"

      declare -gr DarkOrange="$(tput bold)$(tput setaf 178)"
      declare -gr Orange="$(tput bold)$(tput setaf 220)"

      $use256 && declare -gr White="$(tput setaf 231)"               || declare -gr White="$(tput setaf 7)"
      $use256 && declare -gr Gray="$(tput setaf 250)"                || declare -gr Gray="$(tput setaf 7)"

      declare -gr NC=$(tput sgr0) # No color

      # Enable additional formatting for 256 color terminals (on 8 color terminals the formatting likely is implemented as a brighter color rather than a different font)
      declare -gr FMT_BOLD="$(tput bold)"
      declare -gr FMT_UNDERLINE="$(tput smul)"
      declare -gr FMT_REVERSE="$(tput rev)"
  else
      [[ "$TERM" =~ 256color ]] && use256=true
      # Enable additional formatting for 256 color terminals (on 8 color terminals the formatting likely is implemented as a brighter color rather than a different font)
      $use256 && declare -gr FMT_BOLD="$(printf '\033[01m')"      # "\033[4;37m"
      $use256 && declare -gr FMT_UNDERLINE="$(printf '\033[04m')" # "\033[4;37m"
      declare -gr FMT_REVERSE=""
  fi

  if $bEnabled; then
      if $has_tput; then
          # ---------------------- Logging colors ----------------------
          declare -gr CLR_GOOD="$Green"             # Bright Green
          declare -gr CLR_INFORM="$Gray"            # Gray
          declare -gr CLR_WARN="$Yellow"            # Bright Yellow
          declare -gr CLR_DEBUG="$Purple"           # Bright Purple
          declare -gr CLR_BAD="$Red"                # Bright Red
          declare -gr CLR_HILITE="$Cyan"            # Bright Cyan
          declare -gr CLR_BRACKET="$Blue"           # Bright Blue
          declare -gr CLR_NORMAL="$NC"              # no color
      else
          # Escape sequence color table
          # -> https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

          [[ "$TERM" =~ 256color ]] && use256=true || use256=false
          $use256 && declare -gr CLR_GOOD="$(printf '\033[38;5;10m')"    || declare -gr CLR_GOOD="$(printf '\033[32;01m')"
          $use256 && declare -gr CLR_INFORM="$(printf '\033[38;5;2m')"   || declare -gr CLR_INFORM="$(printf '\033[37;01m')"  # change to Gray
          $use256 && declare -gr CLR_DEBUG="$(printf '\033[38;5;11m')"   || declare -gr CLR_DEBUG="$(printf '\033[35;01m')"   # change to Purple
          $use256 && declare -gr CLR_WARN="$(printf '\033[38;5;11m')"    || declare -gr CLR_WARN="$(printf '\033[33;01m')"
          $use256 && declare -gr CLR_BAD="$(printf '\033[38;5;9m')"      || declare -gr CLR_BAD="$(printf '\033[31;01m')"
          $use256 && declare -gr CLR_HILITE="$(printf '\033[38;5;14m')"  || declare -gr CLR_HILITE="$(printf '\033[36;01m')"
          $use256 && declare -gr CLR_BRACKET="$(printf '\033[38;5;12m')" || declare -gr CLR_BRACKET="$(printf '\033[34;01m')"

          declare -gr CLR_NORMAL="$(printf '\033[0m')"
      fi
  fi

  return 0
  }

bfl::declare_terminal_colors
