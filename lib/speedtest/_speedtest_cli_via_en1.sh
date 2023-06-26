#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to speedtest
#
# @author  A. River
#
# @file
# Defines function: bfl::speedtest_cli_via_en1().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @return String $result
#   ..............................
#
# @example
#   bfl::speedtest_cli_via_en1 ...
#------------------------------------------------------------------------------
bfl::speedtest_cli_via_en1() {
  bfl::verify_arg_count "$#" 1 999      || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]";         return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_IFCONFIG} -eq 1 ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'ifconfig' not found";      return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_SPEEDTEST_CLI} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'speedtest-cli' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local en1_ip
  en1_ip="$( ifconfig en1 )" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed ifconfig en1"; return 1; }
  [[ "${en1_ip}" =~ .*[[:blank:]]inet[[:blank:]]+([0-9\.]*).* ]] || { bfl::writelog_fail "${FUNCNAME[0]}: No IP for EN1"; return 1; }

  en1_ip="${BASH_REMATCH[1]}"
  speedtest-cli ${en1_ip:+--source ${en1_ip}} "${@}" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed speedtest-cli ${en1_ip:+--source ${en1_ip}} ${@}"; return 1; }
  return 0
  }
