#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ----------------- https://github.com/labbots/bash-utility/ ------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_file_path().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Finds the directory name from a file path. If it exists on filesystem, print absolute path.
#   If a string, remove the filename and return the path.
#
# @param String $file
#   Input string path.
#
# @return String $path
#   Directory path.
#
# @example
#   bfl::get_file_path "some/path/to/file.txt" --> "some/path/to"
#------------------------------------------------------------------------------
bfl::get_file_path() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; }   # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: path was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  if [[ -e "$1" ]]; then
      local _tmp
      _tmp="$(bfl::get_canonical_path "$1")"
      _tmp="${_tmp%/*}"  # $(dirname "${_tmp}")
      printf '%s' "${_tmp:-/}"
      return 0
  fi

  [[ "$1" == *[!/]* ]] || { printf '/\n'; return 0; }
  local _tmp
  _tmp="${1%%"${1##*[!/]}"}"

  [[ "${_tmp}" == */* ]] || { printf '.\n'; return 0; }

  _tmp=${_tmp%/*} && _tmp="${_tmp%%"${_tmp##*[!/]}"}"
  printf '%s' "${_tmp:-/}"

  return 0
  }
