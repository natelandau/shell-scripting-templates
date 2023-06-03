#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
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
#   The variable to be changed. By default, PATH
#
# @example
#   bfl::path_remove '/usr/local/lib' LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::path_remove() {
  bfl::verify_arg_count "$#" 1 2 || exit 1  # Verify argument count.

  local d NEWPATH
  local IFS=':'
  local PATHVARIABLE=${2:-PATH}
  for d in ${!PATHVARIABLE} ; do
      [[ "$d" != "$1" ]] && NEWPATH="${NEWPATH:+$NEWPATH:}$d"
  done

  export $PATHVARIABLE="$NEWPATH"
  return 0
  }
