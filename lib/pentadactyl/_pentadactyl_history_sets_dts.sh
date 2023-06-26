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
# Defines function: bfl::pentadactyl_history_sets_dts().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ................................
#
# @example
#   bfl::pentadactyl_history_sets_dts
#------------------------------------------------------------------------------
bfl::pentadactyl_history_sets_dts() { bfl::pentadactyl_history_sets | bfl::pentadactyl_history_dts; }
