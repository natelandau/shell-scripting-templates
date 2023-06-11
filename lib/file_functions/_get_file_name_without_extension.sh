#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_file_name_without_extension().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the file name, excluding extension.
#
# @param string $path
#   A relative path, absolute path, or symbolic link.
#
# @return string $file_name_without_extension
#   The file name, excluding extension.
#
# @example
#   bfl::get_file_name_without_extension "./foo/bar.txt"
#------------------------------------------------------------------------------
bfl::get_file_name_without_extension() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  bfl::is_blank "$1" && bfl::writelog_fail "${FUNCNAME[0]}: path was not specified." && return 1

  local ext
  ext=$(bfl::get_file_extension "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: ext=\$(bfl::get_file_extension $1)"; return 1; }
  echo ${1:0:-${#ext}-1}

  return 0
  }
