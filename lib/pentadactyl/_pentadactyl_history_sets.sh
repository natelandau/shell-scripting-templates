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
# Defines function: bfl::pentadactyl_history_sets().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ................................
#
# @example
#   bfl::pentadactyl_history_sets
#------------------------------------------------------------------------------
bfl::pentadactyl_history_sets() {
  eval "$( bfl::pentadactyl_common_source )"

  bfl::pentadactyl_history_commands | sed -n "s/\(${tc_tab}set[^=]*\)=\(..*\)/\1${tc_tab}\2/p" | sort -t"${tc_tab}" -k 1,1g | sed "s/\(${tc_tab}set[^${tc_tab}]*\)${tc_tab}/\1=/"
  }
