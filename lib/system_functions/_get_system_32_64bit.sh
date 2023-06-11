#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# https://github.com/commercialhaskell/stack/blob/master/etc/scripts/get-stack.sh
# @file
# Defines function: bfl::get_system_32_64bit().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines 64- or 32-bit architecture
#
# @return string $system architecture
#    if getconf is available, it will return the arch of the OS, as desired
#    if not, it will use uname to get the arch of the CPU, though the installed
#    OS could be 32-bits on a 64-bit CPU
#
# @example
#   bfl::get_system_32_64bit
#------------------------------------------------------------------------------
bfl::get_system_32_64bit() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return 1; } # Verify argument count.

# Check whether the given command exists
has_getconf() {
  command -v 'getconf' > /dev/null 2>&1
}

  if has_getconf ; then
      [[ $(getconf LONG_BIT | grep -q 64) ]] && echo 64 || echo 32
  else
      case "$(uname -m)" in
        *64) echo 64 ;;
        *)   echo 32 ;;
      esac
  fi

  return 0
  }