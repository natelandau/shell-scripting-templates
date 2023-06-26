#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to manipulations with files
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::get_file_extension().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the file extension.
#
# @param String $path
#   A relative path, absolute path, or symbolic link.
#
# @return String $file_extension
#   The file extension, excluding the preceding period.
#
# @example
#   bfl::get_file_extension "./foo/bar.txt"
#------------------------------------------------------------------------------
bfl::get_file_extension() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local s="$1"
  # Detect some common multi-extensions
  [[ "$s" =~ \.tar\.[gx]z$ ]]   && { echo "${s:0 -6}"; return 0; }
  [[ "$s" =~ \.tar\.bz2$ ]]     && { echo "${s:0 -7}"; return 0; }

  local ext=${s##*.}
  [[ "$s" =~ \.log\.[0-9]+$ ]]  && { echo "${s:0 -4-${#ext}}"; return 0; }

  [[ ${#s} -eq ${#ext} ]] && ext=""
  echo "$ext"
#  [[ ${_BFL_HAS_SED} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency tput not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
#  echo "$s" | sed 's/^.*\.\([^.]*\)$/\1/'
  return 0
  }
