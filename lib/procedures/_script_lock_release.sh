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
# Defines function: bfl::script_lock_release().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Cleanup and exit from a script.
#
# @param Integer $code (optional)
#   Exit code (defaults to 0).
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::script_lock_release
#------------------------------------------------------------------------------
bfl::script_lock_release() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  if [[ -d ${SCRIPT_LOCK:-} ]]; then
      if command rm -rf "${SCRIPT_LOCK}"; then
          bfl::writelog_debug "${FUNCNAME[0]}: Removing script lock"
      else
          bfl::writelog_warn "${FUNCNAME[0]}: script lock could not be removed. Try manually deleting ${Yellow}'${SCRIPT_LOCK}'"
      fi
  fi

  if [[ -n ${TMP_DIR:-} && -d ${TMP_DIR:-} ]]; then
      command rm -r "${TMP_DIR}"
      [[ ${1:-} == 1 && -n "$(ls "${TMP_DIR}")" ]] || bfl::writelog_debug "${FUNCNAME[0]}: removing temp directory"
  fi

  trap - INT TERM EXIT

  return "${1:-0}"
  }
