#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# @file
# Defines function: bfl::get_OS().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Identify the OS the script is run on.
#
# @return String   $result
#     mac / linux / windows
#
# @example
#   bfl::get_OS
#------------------------------------------------------------------------------
bfl::get_OS() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.

  local _uname os
  if _uname=$(command -v uname); then
      case $("${_uname}" | tr '[:upper:]' '[:lower:]') in
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
  else
      return 1
  fi
  printf "%s" "$os"

  return 0
  }
