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
# Defines function: bfl::git_hub_add_upstream().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Adds remote add upstream
#
# @param String $_path (optional)
#   Directory. (Default `pwd`)
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::git_hub_add_upstream  "/some path"
#------------------------------------------------------------------------------
bfl::git_hub_add_upstream() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  [[ -z ${1} ]] && local -r _path=$(pwd) || local -r _path="$1"

  # Verify argument values.
  bfl::is_blank "${_path}" && { bfl::writelog_fail "${FUNCNAME[0]}: \$_path is blank!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local repo repo_up repo_up_url
  repo="${_path#*/Source/*/}"
  repo="${repo%.git}"
  repo_up="$( git hub repo-get "${repo}" source/full_name )" || { bfl::writelog_fail "${FUNCNAME[0]}: git hub repo-get '${repo}' source/full_name"; return 1; }
  repo_up_url="$( git hub repo-get "${repo_up}" ssh_url )"   || { bfl::writelog_fail "${FUNCNAME[0]}: git hub repo-get '${repo_up}' ssh_url"; return 1; }
  [[ -n "${repo_up_url}" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: Is empty result: git hub repo-get '${repo_up}' ssh_url"; return 1; }

  declare -p repo repo_up repo_up_url
  git remote add upstream "${repo_up_url}" || { bfl::writelog_fail "${FUNCNAME[0]}: git remote add upstream '${repo_up_url}'"; return 1; }
  git remote -v

  return 0
  }
