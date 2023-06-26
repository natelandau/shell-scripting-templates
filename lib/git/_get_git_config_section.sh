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
# Defines function: bfl::get_git_config_section().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Gets the git config section from local repository.
#
# @param String $path
#   Git repository path.
#
# @param String $section
#   Section name.
#
# @return String $rslt
#   Git section.
#
# @example
#   bfl::get_git_config_section "/repo" "origin"
#------------------------------------------------------------------------------
bfl::get_git_config_section() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2";      return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_GIT} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  # Verify argument values.
  bfl::is_git_repository "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: path '$1' is not a git repository!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$2" && { bfl::writelog_fail "${FUNCNAME[0]}: git branch name is blank!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local s str=""
  pushd "$1" > /dev/null 2>&1
      s=$(git config --list --local | sed -n "/remote\.$2\..*=/p" | sed "s|^remote\.$2\.|\t|") || { str="${FUNCNAME[0]}: Failed \$(git config --list --local | sed  -n '/remote\.$2\..*=/p' | sed 's|^remote\.$2\.|\t|')"; }
  popd > /dev/null 2>&1

  [[ -n "$str" ]] && { bfl::writelog_fail "$str"; return 1; }

  echo "$s"
  return 0
  }
