#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to Bash Strings
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::is_directory_in_PATH().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Searches path in variable like PATH.
#
# The string ONLY single line
#
# @param String $directory
#   The directory to be searching.
#
# @param String $path_variable (optional)
#   The variable to be checked.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::is_directory_in_PATH '/usr/local' "$LD_LIBRARY_PATH"
#------------------------------------------------------------------------------
bfl::is_directory_in_PATH() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  declare -a arr=()
  local IFS=$':' read -r -a arr <<< "$2"

  local d
  for d in ${arr[@]}; do
      [[ "$d" == "$1" ]] && return 0
  done

  return 1
  }
