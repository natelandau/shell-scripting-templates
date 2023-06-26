#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  A. River
#
# @file
# Defines function: bfl::pwd_env().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Transform tilde in path to ${HOME}.
#
# @param String $args (optional)
#   Directory / directories list to transform. (Default is current directory)
#
# @return String $result
#   Transformed directories list.
#
# @example
#   bfl::pwd_env /path
#------------------------------------------------------------------------------
bfl::pwd_env() {
#  bfl::verify_arg_count "$#" 0 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  declare vars=(
      paths
      curpath
      newpath
      tc_tilde
      )

  declare ${vars[*]}
  printf -v tc_tilde '~'

  paths=( "${@:-${PWD}}" )
  for curpath in "${paths[@]}"; do
      [[ "${curpath}" =~ ^(${HOME}|${tc_tilde})(/.*)?$ ]] && newpath="\${HOME}${BASH_REMATCH[2]}"
      printf '%s\n' "${newpath}"
  done

  return 0
  }
