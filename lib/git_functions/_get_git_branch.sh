#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::get_git_branch().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets a git directory branch name.
#
# @return string $branch
#   Branch name.
#
# @example
#   bfl::get_git_branch
#------------------------------------------------------------------------------
bfl::get_git_branch() {
#  bfl::verify_arg_count "$#" 0 0 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0" && return 1 # Verify argument count.
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
