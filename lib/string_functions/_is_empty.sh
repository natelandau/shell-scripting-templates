#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::is_empty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks if a string is empty ("") or null.
#
# @param string $str
#   The string to check.
#
# @return boolean $result
#        0 / 1 (true/false)
#
# @example
#   bfl::is_empty "foo"
#------------------------------------------------------------------------------
bfl::is_empty() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  # Check the string.
  [[ -z "$1" ]] || return 1
  }
