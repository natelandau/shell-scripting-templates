#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of useful utility functions for compiling sources
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::compare_pkg_versions().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Compares two strings containing version numbers.
#
# @param String $VERSION1
#   String with the first version number.
#
# @param String $VERSION2
#   String with the second version number.
#
# @return Integer $result
#   0  If VERSION1 is lower than VERSION2
#   1  If VERSION1 is equal to VERSION2
#   2  If VERSION1 is higher than VERSION2
#
# @example
#   bfl::compare_pkg_versions "1.0.0-SNAPSHOT" "1.2-dfsg"
#------------------------------------------------------------------------------
bfl::compare_pkg_versions() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -r VERSION1="${1:-}"
  local -r VERSION2="${2:-}"

  # VERSION1 is equal VERSION2
  [[ "${VERSION1}" == "${VERSION2}" ]] && return 1

  # VERSION1 is higher (or equal, but we already checked that) than VERSION2. If not that, it must be lower
  [[ "$( tr ' ' '\n' <<< "${VERSION1} ${VERSION2}" | sort --version-sort --reverse | head -n 1 )" == "${VERSION1}" ]] && return 2 || return 0
  }
