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
# Defines function: bfl::pip_list_vers().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Installs modules with defined version
#
# @param String $pkg_list
#   Python modules list.
#
# @example
#   bfl::pip_list_vers
#------------------------------------------------------------------------------
bfl::pip_list_vers() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; }     # Verify argument count.

  # Verify argument values.
#  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: empty string."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  local pkg
  for pkg in "${@}"; do
      printf '%s # ' "${pkg}"
      pip install "${pkg}"==_ 2>&1 | sed -n 's/, / /g;s/^[[:blank:]]*Could not find a version that satisfies the requirement .*==_ (from versions: \(.*\)).*/\1/p'
  done
  }
