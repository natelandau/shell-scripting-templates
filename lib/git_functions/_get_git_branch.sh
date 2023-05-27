#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
#  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
  local s str
  str=`ls -LA | sed -n '/^\.git$/p'`
  [[ -z "$str" ]] && echo '' && return 0

  str=`git branch --no-color 2> /dev/null`
  [[ -z "$str" ]] && echo '' && return 0
  str=`echo "$str" | sed -n '/^[^*]/p'`
  [[ -n "$str" ]] && str=`echo "$str" | sed '/^[^*]/d'`
  [[ -z "$str" ]] && echo '' && return 0

  s=`parse_git_dirty`
  echo "$str" | sed 's/* \(.*\)/(\1'"$s"')/'
  return 0
  }
