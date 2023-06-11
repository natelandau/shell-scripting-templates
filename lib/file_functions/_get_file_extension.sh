#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_file_extension().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the file extension.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $file_extension
#   The file extension, excluding the preceding period.
#
# @example
#   bfl::get_file_extension "./foo/bar.txt"
#------------------------------------------------------------------------------
bfl::get_file_extension() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && bfl::writelog_fail "${FUNCNAME[0]}: path was not specified." && return 1

  local s="$1"
  [[ "$s" =~ \.tar\.[gx]z$ ]] && echo "${s:0 -6}" && return 0
  echo "$s" | sed 's/^.*\.\([^.]*\)$/\1/'
  return 0
  }
