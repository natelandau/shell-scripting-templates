#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::is_positive_integer().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the argument is a positive integer.
#
# @param string $value_to_test
#   The value to be tested.
#
# @return boolean $result
#        0 / 1 (true/false)
#
# @example
#   bfl::is_positive_integer "8675309"
#------------------------------------------------------------------------------
bfl::is_positive_integer() {
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.

#               ${regex}
  [[ "$1" =~ ^[1-9][0-9]*$ ]] && return 0
  return 1
  }
