#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::get_gcc_compile_options().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets options for compiling by gcc on this machine (without parameters). (from recipes slackware.org)
#
# @param string $architecture
#   architecture.
#
# @return string $gcc_compile_options
#   The options for gcc.
#
# @example
#   bfl::get_gcc_compile_options "x86_64"
#------------------------------------------------------------------------------
bfl::get_gcc_compile_options() {
  local ARCH=$1
  [[ -z "$ARCH" ]] && ARCH=bfl::get_system_architecture

  local SLKCFLAGS
  if [ "$ARCH" = "i486" ]; then
      SLKCFLAGS="-O2 -march=i486 -mtune=i686"
  elif [ "$ARCH" = "s390" ]; then
      SLKCFLAGS="-O2"
  elif [ "$ARCH" = "x86_64" ]; then
      SLKCFLAGS="-O2 -fPIC"
  else
      SLKCFLAGS="-O2"
  fi

  echo "$SLKCFLAGS"
  return 0
}
