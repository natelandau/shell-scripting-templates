#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Git commands
#
#
#
# @file
# Defines function: bfl::get_git_branch().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets a git directory branch name.
#
# @return String $branch
#   Branch name.
#
# @example
#   bfl::get_git_branch
#------------------------------------------------------------------------------
bfl::get_git_branch() {
#  bfl::verify_arg_count "$#" 0 0 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.
#  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
  local s str
  str=$(ls -LA | sed -n '/^\.git$/p')
  [[ -z "$str" ]] && echo '' && return 0

  str=$(git branch --no-color 2> /dev/null)
  [[ -z "$str" ]] && echo '' && return 0

  str=$(echo "$str" | sed -n '/^[^*]/p')
  [[ -n "$str" ]] && str=$(echo "$str" | sed '/^[^*]/d')
  [[ -z "$str" ]] && echo '' && return 0

  s=$(parse_git_dirty)
  echo "$str" | sed 's/* \(.*\)/(\1'"$s"')/'
  return 0
  }
