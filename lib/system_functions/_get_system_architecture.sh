#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_system_architecture().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the type of system architecture (from recipes slackware.org)
#
# @return string $system architecture
#   The type of system architecture.
#
# @example
#   bfl::get_system_architecture
#------------------------------------------------------------------------------
bfl::get_system_architecture() {
  bfl::verify_arg_count "$#" 0 0 || exit 1  # Verify argument count.

#  if [ -z "$ARCH" ]; then
  local str
  str=$(uname -m)
  local ARCH
  case "$str" in
      i?86) ARCH='i486' ;;
      arm*) ARCH='arm' ;;
      # Unless $ARCH is already set, use uname -m for all other archs:
         *) ARCH="$str" ;;
  esac
#  fi
  echo "$ARCH"
  return 0
  }
