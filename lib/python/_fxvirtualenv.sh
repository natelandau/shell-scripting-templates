#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Python
#
# @author  A. River
#
# @file
# Defines function: bfl::fxvirtualenv().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Loads virtualenv
#
# @example
#   bfl::fxvirtualenv
#------------------------------------------------------------------------------
bfl::fxvirtualenv() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; }     # Verify argument count.

  # Verify argument values.
#  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: empty string."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  local sdir vhom vdir venv vflg
  sdir="${pwd}"
  vhom="${WORKON_HOME:-${VIRTUALENVWRAPPER_HOOK_DIR}}"
  vdir="${VIRTUAL_ENV}"
  venv="${1}"
  if [[ -n "${venv}" ]]; then
      vflg=0
      vdir="${vhom}/${venv}"
      [[ -e "${vdir}" ]] || vdir=
  else
      vflg=1
  fi

  [[ -z "${vdir}" ]] && { workon; return "${?}"; }

  venv="${vdir##*/}"
  deactivate > /dev/null 2>&1
  find -L "${vdir}" -type l -exec rm -vf '{}' \
  cd "${vdir}"
  virtualenv .
  cd "${sdir}"
  [[ "${vflg}" -ne 0 ]] && workon "${venv}"

  return 0
  }
