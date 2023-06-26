#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of internal library functions
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::verify_dependencies().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Verifies that dependencies are installed.
#
# @param Array $apps
#   One dimensional array of applications, executables, or commands.
#
# @example
#   bfl::verify_dependencies "curl" "wget" "git"
#------------------------------------------------------------------------------
bfl::verify_dependencies() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1..1999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  declare -ar apps=("$@")
  local app

  for app in "${apps[@]}"; do
      if ! hash "${app}" 2> /dev/null; then
          bfl::writelog_fail "${FUNCNAME[0]}: $app is not installed."
          return 1
      fi
  done
  }
