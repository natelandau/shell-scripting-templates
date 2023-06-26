#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to brew
#
# @author  A. River
#
# @file
# Defines function: bfl::brew_via_proxy().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs brew using proxychains4.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::brew_via_proxy
#------------------------------------------------------------------------------
bfl::brew_via_proxy() {
#  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_PROXYCHAINS4} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'proxychains4' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_BREW} -eq 1 ]]         || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'brew' not found";         return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  proxychains4 -q brew "${@}" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed proxychains4 -q brew '${@}'"; return 1; }

  return 0
  }
