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
  lib::validate_arg_count "$#" 1 999 || return 1
  declare -ar apps=("$@")
  declare app
  declare counter=0
  declare error_state="false"
  declare string

  set +e
  for app in "${apps[@]}"; do
    if ! hash "${app}" 2> /dev/null; then
      lib::err "Error: ${app} is not installed."
      error_state="true"
      ((counter++)) || true
    fi
  done
  set -e
  if [[ "${error_state}" = "true" ]]; then
    if [[ ${counter} -gt 1 ]]; then
      string="applications"
    else
      string="application"
    fi
    lib::err "Error: please install the missing ${string} and try again."
    return 1
  fi
}
