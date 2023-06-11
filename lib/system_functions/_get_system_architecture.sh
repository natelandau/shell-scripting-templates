#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_system_architecture().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines the CPU's instruction set (from recipes slackware.org)
#
# @return string $system architecture
#   The type of system architecture.
#
# @example
#   bfl::get_system_architecture
#------------------------------------------------------------------------------
bfl::get_system_architecture() {
  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return 1; } # Verify argument count.

#  if [ -z "$ARCH" ]; then
  local str
  str=$(uname -m)
  local ARCH
  case "$str" in
      i?86) ARCH='i486' ;;
      arm*) ARCH='arm' ;;
#  uname -m | grep -Eq 'armv[78]l?' => 'arm'
#  uname -m | grep -q aarch64       => 'aarch64'
#  uname -m | grep -q x86           => 'x86'
      # Unless $ARCH is already set, use uname -m for all other archs:
         *) ARCH="$str" ;;
  esac
#  fi
  echo "$ARCH"

  return 0
  }