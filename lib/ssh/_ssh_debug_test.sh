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
# Defines function: bfl::ssh_debug_test().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @param String $ssh_args
#   ssh arguments. Remainder of arguments can be pretty much anything you would otherwise provide to ssh.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::ssh_debug_test "$ssh_args"
#------------------------------------------------------------------------------
bfl::ssh_debug_test() {
#  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SSH} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'ssh' not found";   return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
#  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: parameter 1 is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local s='Applying|identity|Found|key:|load_hostkeys:|Offering)|Authenticat|OKOKOK'
  ssh -vvv -oControlPath=none "${@}" echo OKOKOK 2>&1 |
      egrep --line-buffered '(debug[0-9]: (Reading|.*: '"$s)" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed ssh -vvv -oControlPath=none "${@}" echo OKOKOK 2>&1 | egrep --line-buffered '(debug[0-9]: (Reading|.*: '$s')"; return 1; }

  return 0
  }
