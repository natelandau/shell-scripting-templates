#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::print_args().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Prints the arguments passed to this function.
#
# A debugging tool. Accepts between 1 and 999 arguments.
#
# @param list $arguments
#   One or more arguments.
#
# @example
# bfl::print_args "foo" "bar" "baz"
#------------------------------------------------------------------------------
bfl::print_args() {
  bfl::verify_arg_count "$#" 1 999 || exit 1

  declare -ar args=("$@")
  declare counter=0
  declare arg

  printf "===== Begin output from %s =====\\n" "${FUNCNAME[0]}"
  for arg in "${args[@]}"; do
    ((counter++)) || true
    printf "$%s = %s\\n" "${counter}" "${arg}"
  done
  printf "===== End output from %s =====\\n" "${FUNCNAME[0]}"
}
