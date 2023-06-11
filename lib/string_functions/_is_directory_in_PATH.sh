#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
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
#        0 / 1 (true/false)
#
# @example
#   bfl::is_directory_in_PATH '/usr/local' "$LD_LIBRARY_PATH"
#------------------------------------------------------------------------------
bfl::is_directory_in_PATH() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return 1; } # Verify argument count.

  declare -a arr=()
  local IFS=$':' read -r -a arr <<< "$2"

  local d
  for d in ${arr[@]}; do
      [[ "$d" == "$1" ]] && return 0
  done

  return 1
  }
