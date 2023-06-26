#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Linux Systems
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::terminal_spinner().
#------------------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------------------
source "${BASH_FUNCTION_LIBRARY%/*}"/lib/terminal/_is_Terminal.sh
#------------------------------------------------------------------------------
# @function
#   Creates a spinner within a for/while loop.
#   Don't forget to add bfl::terminal_clear_line() at the end of the loop.
#   Output Progress bar.
#
# @param String $text (Optional)
#   Text accompanying the spinner. (Defaults to 1)
#
# @example
#   for i in $(seq 0 100); do
#     bfl::sleep 0.1
#     bfl::terminal_spinner "Counting numbers"
#   done
#   bfl::terminal_clear_line
#------------------------------------------------------------------------------
bfl::terminal_spinner() {
  [[ $BASH_INTERACTIVE == true ]] || return 0
  [[ $VERBOSE == true ]] && return 0            # Do nothing in quiet/verbose mode.
  bfl::verify_arg_count "$#" 0 1  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; }                     # Verify argument count.
#  bfl::is_Terminal || { bfl::writelog_fail "${FUNCNAME[0]}: no terminal found"; return 1; }                      # Do nothing if the output is not a terminal.
  [[ ${_BFL_HAS_TPUT} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'tput' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_PERL} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'perl' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local s l msg="${1:-Running process}"
  tput civis  # Hide the cursor
  [[ -z ${SPIN_NUM:-} ]] && declare -gi SPIN_NUM=0
  local -i iMax=28

  s=$(bfl::string_of_char '▁' $((iMax-SPIN_NUM)) )
  l=$(bfl::string_of_char '█' $SPIN_NUM)
  local glyph="${l}${s}"

  local -i p=$((100*SPIN_NUM/iMax))
  s="$p"
  [[ $p -lt 100 ]] && s=" $s"
  [[ $p -lt 10 ]]  && s=" $s"

  n=${n//.*/}  # cut floating point!
  # shellcheck disable=SC2154
  printf "\r${Gray}[   $s%%] %s  %s...${reset}" "${glyph}" "${msg}"
  [[ $SPIN_NUM -lt $iMax ]] && ((SPIN_NUM = SPIN_NUM + 1)) || SPIN_NUM=0

  return 0
  }
