#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Java
#
# @author  A. River
#
# @file
# Defines function: bfl::run_javaws().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs java web app file.
#
# @example
#   declare tmp
#   tmp="$( find ~/Downloads/. -type f -name "*.jnlp*" -mmin -5 -print0 | xargs -0 ls -1rUd )"
#   declare -p tmp
#   bfl::run_javaws "$tmp"
#------------------------------------------------------------------------------
bfl::run_javaws() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_JAVAWS} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'javaws' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  echo "$1" | sed -n '$p' | xargs -tI@ javaws -verbose -wait "@"
  }
