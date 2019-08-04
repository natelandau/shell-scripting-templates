#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::verify_dependencies().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Verifies that dependencies are installed.
#
# @param array $apps
#   One dimensional array of applications, executables, or commands.
#------------------------------------------------------------------------------
bfl::verify_dependencies() {
  bfl::verify_arg_count "$#" 1 999 || exit 1

  declare -ar apps=("$@")
  declare app

  for app in "${apps[@]}"; do
    if ! hash "${app}" 2> /dev/null; then
      bfl::die "Error: ${app} is not installed."
    fi
  done
}
