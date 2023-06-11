#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::terminal_progressbar().
#------------------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------------------
source $(dirname "$BASH_FUNCTION_LIBRARY")/lib/terminal_functions/_is_Terminal.sh
#------------------------------------------------------------------------------
# @function
#   Prints a progress bar within a for/while loop. For this to work correctly you.
#   MUST know the exact number of iterations. If you don't know the exact number, use bfl::terminal_spinner().
#   Output Progress bar.
#
# @param Integer $count
#   The total number of items counted.
#
# @param String $title (Optional)
#   The optional title of the progress bar.
#
# @example
#   bfl::terminal_clear_line
#   for i in $(seq 0 100); do
#       bfl::sleep 0.1
#       bfl::terminal_progressbar "100" "Counting numbers"
#   done

#------------------------------------------------------------------------------
bfl::terminal_progressbar() {
  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return 1; }                     # Verify argument count.
#  bfl::function_exists "bfl::isTerminal" || { bfl::writelog_fail "${FUNCNAME[0]}: function isTerminal not found"; return 1; }          # Verify dependencies.

  ( [[ $QUIET == true ]] || [[ $VERBOSE == true ]] || ! [[ $BASH_INTERACTIVE == true ]] ) && return 0            # Do nothing in quiet/verbose mode.
  bfl::is_Terminal || { bfl::writelog_fail "${FUNCNAME[0]}: no terminal found"; return 1; }                      # Do nothing if the output is not a terminal.
  [[ "$1" -eq 1 ]] && return # Do nothing with a single element

  local -i n=$1
  local -i _width=30
  local barCharacter="#"
  local _percentage
  local _num
  local _bar
  local progressBarLine
  local barTitle="${2:-Running Process}"

  ((n=n-1))

  # Reset the count
  [[ -z "${PROGRESS_BAR_PROGRESS:-}" ]] && declare -gi PROGRESS_BAR_PROGRESS=0
  tput civis  # Hide the cursor

  if [[ ${PROGRESS_BAR_PROGRESS} -eq $n ]]; then
      bfl::terminal_clear_line  # Clear the progress bar when complete
      unset PROGRESS_BAR_PROGRESS
      return 0
  fi

  # Compute the percentage.
  _percentage=$((PROGRESS_BAR_PROGRESS * 100 / $1))

  # Compute the number of blocks to represent the percentage.
  _num=$((PROGRESS_BAR_PROGRESS * _width / $1))
  _bar=""   # Create the progress bar string.
                        #_bar=$(printf "%0.s${barCharacter}" $(seq 1 "${_num}"))
  [[ ${_num} -gt 0 ]] && _bar=$(bfl::string_of_char "$barCharacter" ${_num})

  # Print the progress bar.
  progressBarLine=$(printf "%s [%-${_width}s] (%d%%)" "  $barTitle" "${_bar}" "${_percentage}")
  printf "%s\r" "$progressBarLine"

  ((PROGRESS_BAR_PROGRESS=PROGRESS_BAR_PROGRESS + 1))

  return 0
  }
