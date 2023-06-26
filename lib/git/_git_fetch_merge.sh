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
# Defines function: bfl::git_fetch_merge().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Fetches "upstream" and merges "upstream/master" "master"
#
# @param String $stream_and_branch
#   Stream / branch.
#
# @param String $branch2  (optional)
#   Branch №2.
#
# @return Boolan $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::git_fetch_merge "upstream/master" master
#------------------------------------------------------------------------------
bfl::git_fetch_merge() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: parameter 1 is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ "$1" == */* ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: parameter 1 does not look like 'upstream/master'."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r stream="${1##*/}"
  local -r branch1="${1%/*}"

  bfl::is_blank "$stream"  && { bfl::writelog_fail "${FUNCNAME[0]}: git stream name is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$branch1" && { bfl::writelog_fail "${FUNCNAME[0]}: git branch name of stream is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r branch2="${2:-$branch1}"

  git remote -v
  git fetch "$stream"       || { bfl::writelog_fail "${FUNCNAME[0]}: Failed git fetch '$1'"; return 1; }
  git merge "$1" "$branch2" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed git merge '$1' '$branch2'"; return 1; }

  return 0
  }
