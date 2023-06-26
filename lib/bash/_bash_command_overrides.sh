#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Bash
#
# @author  A. River
#
# @file
# Defines function: bfl::bash_command_overrides().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Display list of commands and where they are defined.
#   If called as *_overrides or with --overrides, only show those defined multiple times.
#   Includes BASH Alias/Keyword/Function/Builtin entries.
#
# @param String $args
#   Arguments list.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::bash_command_overrides ....
#------------------------------------------------------------------------------
bfl::bash_command_overrides() { bfl::bash_command_overrides --overrides "${@}"; }
