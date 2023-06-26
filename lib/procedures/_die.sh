#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of internal library functions
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::die().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints a fatal error message to stderr, then exits with status code 1.
#   The message provided will be prepended with "Fatal error. "
#
# @param String $msg (optional)
#   The message.
#
# @param String $msg_color (optional)
#   The message color.
#
# @example
#   bfl::error "The foo is bar."
#------------------------------------------------------------------------------
# shellcheck disable=SC2154
bfl::die() {
  bfl::verify_arg_count "$#" 0 2 || return 1  # Verify argument count.

  # Declare positional arguments (readonly, sorted by position).
  local -r msg="${1:-'Unspecified fatal error.'}"
  local -r msg_color="${2:-$Red}"   # Red

  # Declare all other variables (sorted by name).
  local stack

  # Build a string showing the "stack" of functions that got us here.
  stack="${FUNCNAME[*]}"
  stack="${stack// / <- }"

  [[ $BASH_INTERACTIVE == true ]] && printf "${Red}$msg${NC}\n" > /dev/tty

  #                                ИЛИ     echo "$@" >&2 ???
  # # print a message to stderr and exit with error code
  printf "%b\\n" "${!msg_color}Fatal error. $msg${NC}" 1>&2
  printf "%b\\n" "${Yellow}[$stack]${NC}" 1>&2 # Print the stack.

  return 0
  }
