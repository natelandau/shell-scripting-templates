#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to pb
#
# @author  A. River
#
# @file
# Defines function: bfl::pbc4env().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs pbcopy of ${PBENV}
#
# @example
#   bfl::pbc4env
#------------------------------------------------------------------------------
bfl::pbc4env() {
  [[ ${_BFL_HAS_PBCOPY} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'pbcopy' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  printf %s "${PBENV}" | pbcopy
  }
