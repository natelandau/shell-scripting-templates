#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to the Secure Shell
#
# @author  A. River
#
# @file
# Defines function: bfl::get_ssh_hosts().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints ssh hosts list.
#
# @param String $ssh_known_hosts (optional)
#   ssh known hosts file. Default "$HOME"/.ssh/known_hosts
#
# @return String $result
#   ssh known hosts list
#
# @example
#   bfl::get_ssh_hosts
#------------------------------------------------------------------------------
bfl::get_ssh_hosts() {
  bfl::verify_arg_count "$#" 0 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [0, 1]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  local f="${1:-"$HOME"/.ssh/known_hosts}"
  cut -d, -f1 < "$f" | cut -d' ' -f1 | egrep "${@}" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed cut -d, -f1 < '$f' | cut -d' ' -f1 | egrep '${@}'"; return 1; }
  return 0
  }
