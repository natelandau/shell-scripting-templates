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
# Defines function: bfl::script_lock_acquire().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Acquire script lock to prevent running the same script a second time before the first instance exits.
#   If the lock was acquired it's automatically released in _safeExit_()
#
# @param String $scope (optional)
#   Scope of script execution lock (system or user).
#
# @return String $SCRIPT_LOCK
#   Path to the directory indicating we have the script lock.
#   Exits script if lock cannot be acquired.
#
# @example
#   bfl::script_lock_acquire
#------------------------------------------------------------------------------
bfl::script_lock_acquire() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _lockDir
  _lockDir="${TMPDIR:-/tmp/}${0##*/}"   # $(basename ${0})
  [[ "${1:-}" == 'system' ]] || _lockDir+=".${UID}"
  _lockDir+=".lock"

  # shellcheck disable=SC2120
  if command mkdir "${_lockDir}" 2>/dev/null; then
      readonly SCRIPT_LOCK="${_lockDir}"
      bfl::writelog_debug "${FUNCNAME[0]}: acquired script lock ${Yellow}${SCRIPT_LOCK}${Purple}"
      return 0
  fi

  if declare -f "bfl::script_lock_release" &>/dev/null; then
      bfl::writelog_fail "${FUNCNAME[0]}: Unable to acquire script lock: ${Yellow}${_lockDir}${Red}. If you trust the script isn't running, delete the lock dir"
  else
      [[ $BASH_INTERACTIVE == true ]] && printf "%s\n" "ERROR: Could not acquire script lock. If you trust the script isn't running, delete: ${_lockDir}" > /dev/tty
  fi

  return 1
  }
