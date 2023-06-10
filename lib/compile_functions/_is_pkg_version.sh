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
# Defines function: bfl::is_pkg_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Tests if STRING is a version string .
#
# @param string $value_to_test
#   The value to be tested.
#
# @return Boolan $result
#      0 / 1 (true / false).
#
# @example
#   bfl::is_pkg_version "1.0.0-SNAPSHOT"
#------------------------------------------------------------------------------
#
bfl::is_pkg_version() {
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.

  local -r argument="$1"

  ! [[ "${argument}" =~ ^[[:digit:]]+(\.[[:digit:]]+){0,2}(-[[:alnum:]]+)?$ ]] && return 1
  return 0
  }
