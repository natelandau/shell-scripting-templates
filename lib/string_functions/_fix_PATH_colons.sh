#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::fix_PATH_colons().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Replaces :: => : and trims right and left sides from the beginning and the end of string.
#
# The string ONLY single line
#
# @param string $str
#   The string to fized.
#
# @return string $str
#   The fixed path.
#
# @example
#   bfl::fix_PATH_colons $LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::fix_PATH_colons() {
  local str
  str=`echo "$1" | sed 's/::/:/g'`
  str=`bfd::trimLR "$str" ':' ' '`

  echo "$str"
  return 0
}
