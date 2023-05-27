#!/usr/bin/env bash

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
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r argument="$1"

  ! [[ "${argument}" =~ ^[[:digit:]]+(\.[[:digit:]]+){0,2}(-[[:alnum:]]+)?$ ]] && return 1
}
