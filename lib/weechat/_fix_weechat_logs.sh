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
# Defines function: bfl::fix_weechat_logs().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   .............................
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::fix_weechat_logs
#------------------------------------------------------------------------------
bfl::fix_weechat_logs()
  {
  local -a logs nlogs dtss
  local -- log  nlog  dts  dtsn dtsl dtsc IFS tc_tab

  printf -v tc_tab '\t'

  dtsn="$( date +%s )"
  dtsn="$( date -r "$(( dtsn - ( 48 * 60 * 60 ) ))" +%Y-%m-%d )"

  printf -v IFS '\n'
  logs=(
         $( find ${HOME}/.weechat/logs/irc/rtit_rs/\#nebops/. \
                 -name "*.weechatlog" \
                 -type f \
                 -print
          )
      )
  printf -v IFS ' \t\n'

  for log in "${logs[@]}"; do
      printf -v IFS '\n'
      dtss=(
             $( egrep -no '^[0-9]{4}(.[0-9]{2}){5}' "${log}" |
                sed 's=^[[:blank:]]*\([0-9]*\):\(....\).\(..\).\(..\).\(..\).\(..\).\(..\)=\1:\2\3\4:\5\6\7=' |
                sort -t: -k 2,2g -k 1,1gr |
                sort -t: -k 2,2g -u
              )
           )
      printf -v IFS ' \t\n'

      printf '[ %s ]\t{ %s }\n' "${#dtss[@]}" "${log}"
      printf '( %s - %s )\n' "${dtss[0]}" "${dtss[$((${#dtss[@]}-1))]}"

      break
      continue
      dtsl="${dtss[$((${#dtss[@]}-1))]}"
      [[ "${dtsl}" =~ ([0-9]{4}).([0-9]{2}).([0-9]{2}).([0-9]{2}).([0-9]{2}).([0-9]{2}) ]] && printf -v dtsl %s "${BASH_REMATCH[@]:1}"

      printf -v IFS '\n'
      dtss=(
             $(
                { printf '%s\n' "${dtss[@]%?????????}" "${dtsn}_DELETE"; } | sort -u | sed '/_DELETE$/,$d'
              )
      )
      printf -v IFS ' \t\n'
      if [[ "${#dtss[@]}" -gt 1 ]]; then
          printf '+ { %s }\t[ %s ]\n' "${log}" "${#dtss[@]}"
          for dts in "${dtss[@]}"; do
              nlog="${log%/*}/${dts}.weechatlog"
              printf '> { %s }\n' "${nlog}"
              sed -n  "/^${dts}[ T:\._-]/p" "${log}" >> "${nlog}" && \
                  sed -i~ "/^${dts}[ T:\._-]/d" "${log}"
              nlogs[${#nlogs[@]}]="${nlog}${tc_tab}${dtsl}"
          done
      else
          #printf '= { %s }\t{ %s }\n' "${log}" "${dtss:-current}"
          nlogs[${#nlogs[@]}]="${log}${tc_tab}${dtsl}"
      fi

  done

  return 0
  }
