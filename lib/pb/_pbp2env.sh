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
# Defines function: bfl::pbp2env().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Copy pbpaste to environment variable ${PBENV}.
#
# @example
#   bfl::pbp2env
#------------------------------------------------------------------------------
bfl::pbp2env() {
  [[ ${_BFL_HAS_PBPASTE} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'pbpaste' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  unset PBENV
  export PBENV="$( pbpaste )"
  printf "%s=%q\n" PBENV "${PBENV}"
  }
