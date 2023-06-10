#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::parse_git_dirty().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Checks if current directory is a git directory.
#
# @return string $str
#   * / nothing.
#
# @example
#   bfl::parse_git_dirty
#------------------------------------------------------------------------------
bfl::parse_git_dirty() {
#  bfl::verify_arg_count "$#" 0 0 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 0"  # Verify argument count.
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "*"
  }
