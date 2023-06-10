#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
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
  bfl::verify_arg_count "$#" 1 999 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [1...1999]"  # Verify argument count.

  declare -ar args=("$@")
  local arg counter=0

  printf "===== Begin output from %s =====\\n" "${FUNCNAME[0]}"

  for arg in "${args[@]}"; do
    ((counter++)) || true
    printf "$%s = %s\\n" "$counter" "$arg"
  done

  printf "===== End output from %s =====\\n" "${FUNCNAME[0]}"
  return 0
  }
