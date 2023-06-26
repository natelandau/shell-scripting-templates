#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Linux Systems
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_OS().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Identify the OS the script is run on.
#
# @return String   $result
#   mac / linux / windows
#
# @example
#   bfl::get_OS
#------------------------------------------------------------------------------
bfl::get_OS() {
  bfl::verify_arg_count "$#" 0 0   || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0";            return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
#  [[ ${_BFL_HAS_UNAME} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'uname' is not found!"; return ${BFL_ErrCode_Not_verified_dependency}; }

  local os
  case "${OSTYPE,,}" in
#  case $( uname | tr '[:upper:]' '[:lower:]' ) in
      linux*)
          os="linux" ;;
      darwin*)
          os="mac" ;;
      msys* | cygwin* | mingw* | nt | win*)
          # or possible 'bash on windows'
          os="windows" ;;
      *)
          return 1 ;;
  esac

  printf "%s" "$os"

  return 0
  }
