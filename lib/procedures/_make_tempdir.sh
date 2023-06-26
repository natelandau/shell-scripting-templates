#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::make_tempdir().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Creates a temp directory to house temporary files.
#
# @param String $word (optional)
#   First characters/word of directory name.
#
# @return String $result
#   Sets $TMP_DIR variable to the path of the temp directory.
#
# @example
#   bfl::make_tempdir "$(basename "$0")"
#------------------------------------------------------------------------------
bfl::make_tempdir() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  [[ -d "${TMP_DIR:-}" ]] && return 0

  TMP_DIR="${TMPDIR:-/tmp/}"
  [[ -n "${1:-}" ]] && TMP_DIR+="${1}" || TMP_DIR+="${0##*/}.${RANDOM}"    #"$(basename "$0").${RANDOM}"
  TMP_DIR+=".${RANDOM}.${RANDOM}.$$"

  (umask 077 && mkdir "${TMP_DIR}") || { bfl::writelog_fail "${FUNCNAME[0]}: Could not create temporary directory! Exiting."; return 1; }
  bfl::writelog_debug "\$TMP_DIR=${TMP_DIR}"

  return 0
  }
