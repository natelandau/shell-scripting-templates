#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to terminal
#
#
#
# @file
# Defines function: bfl::terminal_clear_line().
#------------------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------------------
source "${BASH_FUNCTION_LIBRARY%/*}"/lib/terminal/_is_Terminal.sh
#------------------------------------------------------------------------------
# @function
#   Clears output in the terminal up to the specified line number. Removes previous line.
#
# @param String $Line_No  (Optional)
#   Line number to clear. (Defaults to 1)
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::terminal_clear_line 2
#------------------------------------------------------------------------------
bfl::terminal_clear_line() {
  [[ $BASH_INTERACTIVE == true ]] || return 0
  [[ $VERBOSE == true ]] && return 0            # Do nothing in quiet/verbose mode.
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]";  return ${BFL_ErrCode_Not_verified_args_count}; }   # Verify argument count.
#  $(bfl::is_Terminal) || { bfl::writelog_fail "${FUNCNAME[0]}: no terminal found"; return 1; }  # Do nothing if the output is not a terminal
  [[ ${_BFL_HAS_TPUT} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'tput' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  local -ir num="${1:-1}"
  local -i i=0
  tput cnorm  # Replace the cursor
  for ((i = 0; i < num; i++)); do
      printf "\r\033[0K"    # printf "\033[A\033[2K"
  done
  tput cnorm  # Replace the cursor

  [[ -z ${SPIN_NUM+x} ]] || unset SPIN_NUM   # Clear the spinner
  return 0
  }
