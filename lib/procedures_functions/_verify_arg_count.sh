#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::verify_arg_count().
#------------------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------------------
source $(dirname "$BASH_FUNCTION_LIBRARY")/lib/declaration_functions/_declare_terminal_colors.sh
#------------------------------------------------------------------------------
# @function
# Verifies the number of arguments received against expected values.
#
# Other functions in this library call this function to verify the number of
# arguments received. To prevent infinite loops, this function must not call
# any other function in this library, other than bfl::die.
#
# That is why we are essentially recreating:
# - bfl::verify_arg_count()
# - bfl::is_integer()
#
# @param int $actual_arg_count
#   Actual number of arguments received.
# @param int $expected_arg_count_min
#   Minimum number of arguments expected.
# @param int $expected_arg_count_max
#   Maximum number of arguments expected.
#
# @example
#   bfl::verify_arg_count "$#" 2 3
#
# shellcheck disable=SC2154
#------------------------------------------------------------------------------
bfl::verify_arg_count() {
# циклическая зависимость!
  self_die() {
    # Declare positional arguments (readonly, sorted by position).
    local -r msg="${1:-"Unspecified fatal error."}"
    local -r msg_color="${2:-Red}"   # Red

    # Declare all other variables (sorted by name).
    local stack

    # Build a string showing the "stack" of functions that got us here.
    stack="${FUNCNAME[*]}"
    stack="${stack// / <- }"

  #  ????
  #  [[ $BASH_INTERACTIVE == true ]] && printf "${Red}Не указан ни один параметр функции getHeaderForSection${NC}\n" > /dev/tty

    # Print the message.
    printf "%b\\n" "${!msg_color}Fatal error. $msg${NC}" 1>&2

    # Print the stack.
    printf "%b\\n" "${Yellow}[$stack]${NC}" 1>&2
    }
  # Verify argument count.
  [[ "$#" -ne "3" ]] && self_die "Invalid number of arguments. Expected 3, received $#." && return 1

  # Make sure all of the arguments are integers.
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
      self_die "\"$1\" is not an integer."; return 1
  fi
  if ! [[ "$2" =~ ^[0-9]+$ ]]; then
      self_die "\"$2\" is not an integer."; return 1
  fi
  if ! [[ "$3" =~ ^[0-9]+$ ]]; then
      self_die "\"$3\" is not an integer."; return 1
  fi

  # Test.
  local errmsg

  if [[ $1 -lt $2 || $1 -gt $3 ]]; then
      errmsg="Invalid number of arguments. Expected "
      [[ $2 -eq $3 ]] && errmsg+="$2, received $1." || errmsg+="between $2 and $3, received $1."

      printf "%b\\n" "${Red}Error. ${errmsg}${NC}" 1>&2
      return 1
  fi

  return 0
  }