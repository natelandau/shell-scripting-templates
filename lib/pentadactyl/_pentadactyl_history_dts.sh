#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to pentadactyl
#
# @author  A. River
#
# @file
# Defines function: bfl::pentadactyl_history_dts().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ................................
#
# @example
#   bfl::pentadactyl_history_dts
#------------------------------------------------------------------------------
bfl::pentadactyl_history_dts() {
  eval "$( bfl::pentadactyl_common_source )"

  while read -r ent; do
      dts="${ent%%${tc_tab}*}"
      dts="${dts%??????}"
      date -j -f %s "+%Y-%m/%d %H:%M:%S" "${dts}" 2>/dev/null || echo _ERR_
      echo "${ent}"
  done | paste - -
  }
