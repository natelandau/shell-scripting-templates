#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Linux Systems
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::is_internet_available().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Checks if internet connection is available.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_internet_available
#------------------------------------------------------------------------------
bfl::is_internet_available() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  if $(bfl::is_Terminal); then
      local -r checkInternet="$(sh -ic 'exec 3>&1 2>/dev/null; { curl --compressed -Is google.com 1>&3; kill 0; } | { sleep 10; kill 0; }' || :)"
  else
      local -r checkInternet="$(curl --compressed -Is google.com -m 10)"
  fi
  [[ -z "$checkInternet" ]] && return 1 || return 0
  }
