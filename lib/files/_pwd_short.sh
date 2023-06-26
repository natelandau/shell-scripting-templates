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
# Defines function: bfl::pwd_short().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Transform ${HOME} in path to tilde.
#
# @param String $args (optional)
#   Directory / directories list to transform. (Default is current directory)
#
# @return String $result
#   Transformed directories list.
#
# @example
#   bfl::pwd_short /path
#------------------------------------------------------------------------------
bfl::pwd_short() {
#  bfl::verify_arg_count "$#" 0 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  declare vars=(paths curpath newpath tc_tilde)
  declare ${vars[*]}

  printf -v tc_tilde '~'

  paths=( "${@:-${pwd}}" )

  for curpath in "${paths[@]}"; do
      [[ "${curpath}" =~ ^${HOME}(/.*)?$ ]] && newpath="${tc_tilde}${BASH_REMATCH[1]}"
      printf '%s\n' "${newpath}"
  done

  return 0
  }
