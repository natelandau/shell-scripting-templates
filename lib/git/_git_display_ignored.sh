#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Git commands
#
# @author  A. River
#
# @file
# Defines function: bfl::git_display_ignored().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @example
#   bfl::git_display_ignored
#------------------------------------------------------------------------------
bfl::git_display_ignored()  {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  local tc_tab
  printf -v tc_tab '\t'                                                        # ????
  git ls-files --others | git check-ignore --verbose --stdin | sed "s/:/${tc_tab}/;s/:/${tc_tab}/" | { [[ -t 1 ]] && column -ts"${tc_tab}" || cat -; }

  return 0
  }
