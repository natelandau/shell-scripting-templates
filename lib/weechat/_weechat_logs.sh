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
# Defines function: bfl::weechat_logs().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ...............................
#
# @param Integer $age
#   Age.
#
# @param String $args
#   Arguments list.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::weechat_logs
#------------------------------------------------------------------------------
bfl::weechat_logs() {
  declare vars____=(
      IFS
      tc_tab
      age
      grep_args
      log_dir
      )
  declare ${vars____[*]}

  bfl::weechat_init

  printf -v IFS    ' \t\n'
  printf -v tc_tab '\t'
  [[ -t 1 ]] && local -r flg_file1=1 || local -r flg_file1=0

  log_dir="${WEECHAT_LOG_DIR}"

  age="${1:-1}"
  [[ "${#}" -eq 0 ]] || shift
  [[ "${#}" -eq 0 ]] \
      && grep_args=( -w $( date "+%Y-%m-%d" ) ) \
      || grep_args=( "${@}" )

  find "${log_dir}" -mmin -$(( age * 24 * 60 )) -type f -name "*.weechatlog" -print0 |
      xargs -0 grep -Hn "${grep_args[@]}" |
      sed -e :FIX \
          -e "s=${tc_tab}${tc_tab}=${tc_tab}.${tc_tab}=;tFIX" \
          -e "s=^${log_dir}/==" \
          -e "s=^\([^/]*\)/\([^/]*\)/\([^/]*\)/\([^/]*\)\.weechatlog:\([0-9]*\):=\1${tc_tab}\2${tc_tab}\3${tc_tab}\4${tc_tab}\5${tc_tab}=" \
          -e "s=^\([^/]*\)/\([^/]*\)/\([^/]*\)\.weechatlog:\([0-9]*\):=\1${tc_tab}\2${tc_tab}.${tc_tab}\3${tc_tab}\4${tc_tab}=" \
          -e :END |
      sort -t"${tc_tab}" -k 6,6 -k 1,1 -k 2,2 -k 3,3 -k 5,5g |
      cut -f1-3,6- |
      { [[ "${flg_file1}" -eq 1 ]] && { column -ts"${tc_tab}" | grep --color "${grep_args[@]}"; } || cat -; }

  return 0
  }
