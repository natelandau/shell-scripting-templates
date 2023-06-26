#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to weechat
#
# @author  A. River
#
# @file
# Defines function: bfl::weechat_init().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Exports 2 weechat variables.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::weechat_init
#------------------------------------------------------------------------------
bfl::weechat_init() {
#  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  : ${WEECHAT_HOME_DIR:=${HOME}/.weechat}
  : ${WEECHAT_LOG_DIR:=${WEECHAT_HOME_DIR}/logs}

  local IFS fnc ents ent typ tmp
  printf -v IFS   ' \t\n'
  fnc="${FUNCNAME}"
  ents=( WEECHAT_HOME_DIR WEECHAT_LOG_DIR )

  for ent in "${ents[@]}"; do
      printf -v tmp 'tmp="${%s}"' "${ent}"
      eval "${tmp}"
      [[ -r "${tmp}" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: Could not find ${ent} ( ${tmp} )!"; return 1; }
      export "${ent}"
  done 1>&2

  return 0
  }
