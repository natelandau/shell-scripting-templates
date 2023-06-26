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
# Defines function: bfl::git_hub_unwatch_rkr_forks().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::git_hub_unwatch_rkr_forks
#------------------------------------------------------------------------------
bfl::git_hub_unwatch_rkr_forks() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  local watching repo
  watching="$(git-hub watching | sed -n 's/^[0-9]*) //p' )"
  for repo in $(
      echo "${watching}" |
      egrep "/$(
          echo "${watching}" | egrep '^(racker|rackerlabs)/' | cut -d/ -f2 | sort -u | paste -sd'|' - )\$" |
      egrep -v '^(racker|rackerlabs)/'
      ); do
      git-hub unwatch "${repo}"
  done

  return 0
  }
