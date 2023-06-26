#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to ldaps
#
# @author  A. River
#
# @file
# Defines function: bfl::ldaps().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs ldapsearch - Unwrap ldif output
#
# @param String $ldaps_args
#   ldaps arguments. Remainder of arguments can be pretty much anything you would otherwise provide to ldaps.
#
# @return String $result
#   Text.
#
# @example
#   bfl::ldaps ...
#------------------------------------------------------------------------------
bfl::ldaps() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_AWK} -eq 1 ]]        || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'awk' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_LDAPSEARCH} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'ldapsearch' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  ldapsearch "$@" | awk '(!sub(/^[[:blank:]]/,"")&&FNR!=1){printf("\n")};{printf("%s",$0)};END{printf("\n")}' || { bfl::writelog_fail "${FUNCNAME[0]}: ldapsearch '$@' | awk ..."; return 1; }
  return 0
  }
