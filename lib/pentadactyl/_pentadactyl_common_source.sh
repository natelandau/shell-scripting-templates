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
# Defines function: bfl::pentadactyl_common_source().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Declares common variables for pentadactyl functions
#
# @example
#   bfl::pentadactyl_common_source
#------------------------------------------------------------------------------
bfl::pentadactyl_common_source() {
  declare vars=(
      tmp
      tc_tab
      ent
      cmd
      prv
      val
      dts
      )
  declare ${vars[*]}
  printf -v tc_tab '\t'
  declare -p ${vars[*]}
  }
