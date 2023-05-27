#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::is_directory_in_PATH().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Searches path in variable like PATH.
#
# The string ONLY single line
#
# @param string $directory
#   The directory to be searching.
#
# @param string $path_variable (optional)
#   The variable to be checked.
#
# @return bool $value
#   true/false
#
# @example
#   bfl::is_directory_in_PATH '/usr/local' "$LD_LIBRARY_PATH"
#------------------------------------------------------------------------------
bfl::is_directory_in_PATH() {
  local d
  local b=false; local arr=()
  IFS=$':' read -r -a arr <<< "$2"
  unset IFS
  for d in ${arr[@]}; do
      [[ "$d" == $1 ]] && b=true && break
  done

  echo $b
  return 0
}
