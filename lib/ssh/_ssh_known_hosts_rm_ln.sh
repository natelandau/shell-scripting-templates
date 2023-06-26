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
# Defines function: bfl::ssh_known_hosts_rm_ln().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @param String $ssh_known_hosts
#   ssh known hosts file. Default "$HOME"/.ssh/known_hosts
#
# @param String $ssh_args
#   ssh arguments. Remainder of arguments can be pretty much anything you would otherwise provide to ssh.
#
# @return Boolan $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::ssh_known_hosts_rm_ln "$HOME"/.ssh/known_hosts "$ssh_args"
#------------------------------------------------------------------------------
bfl::ssh_known_hosts_rm_ln() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SSH} -eq 1 ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'ssh' not found";   return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: ssh hosts file is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$1" ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: ssh hosts file didn't defined!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local f="$1"; shift

  declare line
  for line in "${@}"; do
      printf "${FUNCNAME}: Removing line [ %s ]\n" "${line}"
      sed -i~ "${line}d" "$f"
  done

  return 0
  }
