#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Git commands
#
#
#
# @file
# Defines function: bfl::merge_git_repositories().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Gets the git config section from local repository.
#
# @param String $Git_path1
#   Git repository path.
#
# @param String $branch1
#   Repository1 branch.
#
# @param String $Git_path2
#   Git repository path.
#
# @param String $branch2
#   Repository2 branch.
#
# @param String $editor
#   Git editor (default xed).
#
# @return String $rslt
#   Git section.
#
# @example
#   bfl::merge_git_repositories "/etc/bash_functions_library" "master"  "~/scripts/Jarodiv" "master"
#------------------------------------------------------------------------------
bfl::merge_git_repositories() {
  bfl::verify_arg_count "$#" 4 4  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.
  bfl::verify_dependencies "git"  || { bfl::writelog_fail "${FUNCNAME[0]}: dependency shuf not found" ; return $BFL_ErrCode_Not_verified_dependency; } # Verify dependencies.

  # Verify argument values.
  bfl::is_git_repository "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: path '$1' is not a git repository!"; return $BFL_ErrCode_Not_verified_arg_values; }
  bfl::is_git_repository "$3" || { bfl::writelog_fail "${FUNCNAME[0]}: path '$3' is not a git repository!"; return $BFL_ErrCode_Not_verified_arg_values; }

  i=$(sed -n '/^\[remote "origin"\]$/=' "$3"/.git/config)

  cd /etc/bash_functions_library
  local o="${1##*/}"  # $(basename "$1")
  local s="${3##*/}"  # $(basename "$3")
  git remote add "$s" "$3"
  git fetch "$s" --tags
  git commit -m 'Commit before merging "$s" into "$o"'
  GIT_EDITOR=${5:-xed} git merge --allow-unrelated-histories "$s"/"$b2"
  git push origin "$b1"
  git remote remove "$s"

  return 0
  }

#  mkdir ab
#  cd ab
#  git clone git@github.com:AlexeiKharchev/a
#  git clone git@github.com:AlexeiKharchev/b
#  cd a
#  git remote add b ../b
#  git fetch b --tags
#  git commit -m 'temp commit'
#  editor=xed git merge --allow-unrelated-histories b/main
#  git push origin main
#  git remote remove b
