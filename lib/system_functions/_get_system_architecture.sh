#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::get_architecture().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the type of system architecture (from recipes slackware.org)
#
# @return string $canonical_directory_path
#   The type of system architecture.
#
# @example
#   bfl::get_architecture
#------------------------------------------------------------------------------
bfl::get_architecture() {
#  if [ -z "$ARCH" ]; then
    local str="$( uname -m )"
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
