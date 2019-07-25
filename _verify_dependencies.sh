#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::verify_dependencies().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Verifies that dependencies are installed.
#
# @param array $apps
#   One dimensional array of applications, executables, or commands.
#------------------------------------------------------------------------------
lib::verify_dependencies() {
  lib::validate_arg_count "$#" 1 999 || exit 1

  declare -ar apps=("$@")
  declare app

  set +e
  for app in "${apps[@]}"; do
    if ! hash "${app}" 2> /dev/null; then
      lib::die "Error: ${app} is not installed."

    fi
  done
  set -e
}
