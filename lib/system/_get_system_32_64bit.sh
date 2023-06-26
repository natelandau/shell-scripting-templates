#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh
#
# Library of functions related to Linux Systems
#
#
#
# @file
# Defines function: bfl::get_system_32_64bit().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Determines 64- or 32-bit architecture
#
# @return String $system architecture
#    if getconf is available, it will return the arch of the OS, as desired
#    if not, it will use uname to get the arch of the CPU, though the installed
#    OS could be 32-bits on a 64-bit CPU
#
# @example
#   bfl::get_system_32_64bit
#------------------------------------------------------------------------------
bfl::get_system_32_64bit() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  if bfl::command_exists 'getconf'; then
      [[ $(getconf LONG_BIT | grep -q 64) ]] && echo 64 || echo 32
  else
      case "$(uname -m)" in
        *64) echo 64 ;;
        *)   echo 32 ;;
      esac
  fi

  return 0
  }
