#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Bash Strings
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::escape_special_symbols().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Escapes all special characters in STRING.
#
# @param string $STRING
#   The string to be tested.
#
# @return Boolan $result
#   String with escaped special characters.
#
# @example
#   bfl::escape_special_symbols "some string"
#------------------------------------------------------------------------------
#
bfl::escape_special_symbols() {
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.

  [[ -z "$1" ]] && echo '' && return 0

  printf -v var '%q\n' "$1"
  echo "$var"
  }
