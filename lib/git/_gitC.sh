#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to Git commands
#
# @author  A. River
#
# @file
# Defines function: bfl::gitC().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @example
#   bfl::gitC
#------------------------------------------------------------------------------
bfl::gitC ()  {
#  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_COMPGEN} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'compgen' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local tmps tmp rgx tc_tab

  printf -v tc_tab    '\t'

  rgx='^([^[:blank:]]*).*[[:blank:]]git commit -m "([^"]*)"'

  for tmp in $( compgen -c bfl::gitC ); do
      [[ "${tmp}" == "bfl::gitC" ]] && continue
      tmp="$( declare -f "${tmp}" )"
      [[ "${tmp}" =~ ${rgx} ]] || continue
      printf '%s\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
  done

  return 0
  }
