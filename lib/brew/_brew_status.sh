#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to brew
#
# @author  A. River
#
# @file
# Defines function: bfl::brew_status().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Brew package status modeled after output of aptitude
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::brew_status
#------------------------------------------------------------------------------
bfl::brew_status() {
#  bfl::verify_arg_count "$#" 1 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_BREW} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'brew' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  declare -x IFS
  declare -a brews_ents brewl_ents
  local tc_tab ent

  printf -v tc_tab '\t'
  printf -v IFS    '\n'

  for ent in "${@}"; do
      brews_ents=( "${brews_ents[@]}" $( brew search "${ent}" ) )
  done

  for ent in "${brews_ents[@]}"; do
      brewl_ents=( "${brewl_ents[@]}" $( brew list | grep -i "${ent}" ) )
  done

  comm <( printf '%s\n' "${brews_ents[@]}" ) <( printf '%s\n' "${brewl_ents[@]}" ) |
      sed -e "s/^${tc_tab}${tc_tab}/i   /;tEND" \
          -e "s/^${tc_tab}/i?  /;tEND" \
          -e "s/^/p   /;tEND" \
          -e :END

  return 0
  }
