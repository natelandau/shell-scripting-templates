#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of internal library functions
#
# @author  A. River
#
# @file
# Defines function: bfl::declare_vars_diff().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ........................
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::declare_vars_diff
#------------------------------------------------------------------------------
bfl::declare_vars_diff() {
#  bfl::verify_arg_count "$#" 0 0  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 0";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  local ___declare_vars_diff_diff ___declare_vars_diff_snap ___declare_vars_diff_args

  ___declare_vars_diff_args=(
      -BASH_LINENO
      -BASH_REMATCH
      -BASH_SUBSHELL
      -LINENO
      -RANDOM
      -SECONDS
      -_
      )

  ___declare_vars_diff_snap="$(
    bfl::declare_vars "${___declare_vars_diff_args[@]}" |
    sed 's/^\(declare  *[^ ]*  *\)/\1=/' | sort -t= -k 2,2 | sed 's/=//'
    )"

  [[ "${#___DECLARE_VARS_DIFF_SNAPS[@]}" -lt 1 || "${1}" == "init" ]] && { ___DECLARE_VARS_DIFF_SNAPS=( "${___declare_vars_diff_snap}" ); return 0; }

  ___declare_vars_diff_diff="$(
      diff \
          <(  printf '%s\n' "${___DECLARE_VARS_DIFF_SNAPS[@]}" |
                  grep -nw . |
                  sed -e 's/^\([0-9]*\):\(declare  *[^ ]*  *\)/\1=\2=/' \
                      -e 's/^\([0-9]*\):\(unset  *\)/\1=\2=/' \
                      -e :END |
                  sort -t= -k 3,3 -k 1,1gr |
                  sort -t= -k 3,3 -u |
                  sed 's/^[^=]*=//;s/=//'
          ) \
          <( printf '%s\n' "${___declare_vars_diff_snap}" )
      )"

  unset ___declare_vars_diff_snap
  [[ -z "${___declare_vars_diff_diff}" ]] && return 0

  printf '%s\n' "${___declare_vars_diff_diff}"
  #printf '%s\n' "${___declare_vars_diff_diff}" |
  #    sed -n \
  #        -e 's/^[<>] declare  *[^ ]*  *\([^=]*\)=.*/\1/p' \
  #        -e 's/^[<>] unset  *\([^ ]*\).*/\1/p' \
  #        -e :END

  ___declare_vars_diff_diff="$( printf '%s\n' "${___declare_vars_diff_diff}" | sed -n 's/^> //p' )"
  ___DECLARE_VARS_DIFF_SNAPS[${#___DECLARE_VARS_DIFF_SNAPS[@]}]="${___declare_vars_diff_diff}"

  return 0
  }
