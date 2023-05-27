#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Bash Strings
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::is_natural_number().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the argument is a natural number.
#
# @param string $value_to_test
#   The value to be tested.
#
# @example
#   bfl::is_natural_number "8675309"
#------------------------------------------------------------------------------
#
bfl::is_natural_number() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r argument="$1"
#  declare -r regex="^-{0,1}[0-9]+$"
#                          ${regex}
  ! [[ "${argument}" =~ ^[0-9]+$ ]] && return 1
}
