#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::path_remove().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Searches and removes path from variable like PATH.
#
# Standart Linux path functions. The string ONLY single line
#
# @param string $directory
#   The directory to be searching and remove.
#
# @param string $path_variable (optional)
#   The variable to be changed. By default, $PATH
#
# @example
#   bfl::path_remove '/usr/local' "$LD_LIBRARY_PATH"
#------------------------------------------------------------------------------
bfl::path_remove() {
  local DIR NEWPATH
  local IFS=':'
  local PATHVARIABLE=${2:-PATH}
  for DIR in ${!PATHVARIABLE} ; do
    [[ "$DIR" != "$1" ]] && NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
  done

  export $PATHVARIABLE="$NEWPATH"
  return 0
}
