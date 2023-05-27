#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::parse_git_dirty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets a git directory branch name.
#
# @return string $branch
#   Branch name.
#
# @example
#   bfl::parse_git_dirty
#------------------------------------------------------------------------------
bfl::parse_git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "*"
  }
