#!/usr/bin/env bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Git commands
#
#
#
# @file
# Defines function: bfl::is_git_repository().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Determines if a path is local repository.
#
# @param String $path
#   Git repository path.
#
# @return boolean $result
#     0 / 1    (true / false)
#
# @example
#   bfl::is_git_repository "/repo"
#------------------------------------------------------------------------------
bfl::is_git_repository() {
  bfl::verify_arg_count "$#" 1 1  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1";      return $BFL_ErrCode_Not_verified_args_count; } # Verify argument count.
  bfl::verify_dependencies "git"  || { bfl::writelog_fail "${FUNCNAME[0]}: dependency shuf not found" ; return $BFL_ErrCode_Not_verified_dependency; } # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: git repository path was not specified.";  return $BFL_ErrCode_Not_verified_arg_values; }
  [[ -d "$1" ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: directory '$1' doesn't exist!";           return $BFL_ErrCode_Not_verified_arg_values; }
  [[ -d "$1"/.git ]] || { bfl::writelog_fail "${FUNCNAME[0]}: there is no /.git directory in '$1'!";    return $BFL_ErrCode_Not_verified_arg_values; }

  local str
  pushd "$1" > /dev/null 2>&1
      git config --list --local > /dev/null 2>&1 || { str="${FUNCNAME[0]}: Failed \$(git config --list --local)"; }
  popd > /dev/null 2>&1

  [[ -n "$str" ]] && { bfl::writelog_fail "$str"; return 1; }

  return 0
  }
