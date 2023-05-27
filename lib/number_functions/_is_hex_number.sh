#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Bash Strings
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::is_hex_number().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if the argument is a hexadecimal number.
#
# @param string $value_to_test
#   The value to be tested.
#
# @example
#   bfl::is_hex_number "DFFFF8"
#------------------------------------------------------------------------------
#
bfl::is_hex_number() {
  bfl::verify_arg_count "$#" 1 1 || exit 1

  declare -r argument="$1"

  ! [[ "${argument}" =~ ^[0-9a-fA-F]+$ ]] && return 1
}
