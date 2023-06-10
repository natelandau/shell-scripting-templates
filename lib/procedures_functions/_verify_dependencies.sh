#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::verify_dependencies().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Verifies that dependencies are installed.
#
# @param array $apps
#   One dimensional array of applications, executables, or commands.
#
# @example
#   bfl::verify_dependencies "curl" "wget" "git"
#------------------------------------------------------------------------------
bfl::verify_dependencies() {
  bfl::verify_arg_count "$#" 1 999 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [1...1999]"  # Verify argument count.

  declare -ar apps=("$@")
  local app

  for app in "${apps[@]}"; do
      if ! hash "${app}" 2> /dev/null; then
          bfl::die "${app} is not installed."
      fi
  done
  }
