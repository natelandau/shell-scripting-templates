#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to screen and pictures.
#
# @author  A. River
#
# @file
# Defines function: bfl::grab2clip().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Captures screen to buffer.
#
# @example
#   bfl::grab2clip
#------------------------------------------------------------------------------
bfl::grab2clip() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SCREENCAPTURE} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'screencapture' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  [[ $BASH_INTERACTIVE == true ]] && printf '\n'
  screencapture -h 2>&1 | sed '1,/^ *-i /d;/^ *-m /,$d;s/^             //' || { bfl::writelog_fail "${FUNCNAME[0]}: Failed screencapture -h 2>&1 | sed '..."; return ${BFL_ErrCode_Not_verified_dependency}; }
  [[ $BASH_INTERACTIVE == true ]] && printf '\n'

  screencapture -cio || { bfl::writelog_fail "${FUNCNAME[0]}: Failed screencapture -cio"; return ${BFL_ErrCode_Not_verified_dependency}; }
  return 0
  }
