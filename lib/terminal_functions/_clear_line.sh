#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::clear_line().
#------------------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------------------
source $(dirname "$BASH_FUNCTION_LIBRARY")/lib/terminal_functions/_is_Terminal.sh
#------------------------------------------------------------------------------
# @function
# Clears output in the terminal on the specified line number.
#
# @param string $Line_No (optional)
#   Line number to clear. (Defaults to 1)
#
# @return Boolean $result
#   0 / 1   true / false
#
# @example
#   bfl::clear_line "2"
#------------------------------------------------------------------------------
bfl::clear_line() {
#  bfl::verify_arg_count "$#" 0 1 || exit 1  # Verify argument count.
#  bfl::verify_dependencies "bfl::isTerminal"  # Verify dependencies.

  local -ir num="${1:-1}"
  local i
  for ((i = 0; i < num; i++)); do
      printf "\033[A\033[2K"
  done

  return 0
  }
