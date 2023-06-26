#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to opensnoops
#
# @author  A. River
#
# @file
# Defines function: bfl::opensnoops().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs opensnoops from sudo with parameters.
#
# @param String $opensnoop_args
#   opensnoop arguments. Remainder of arguments can be pretty much anything you would otherwise provide to opensnoop.
#
# @return String $result
#   Text.
#
# @example
#   bfl::opensnoops ...
#------------------------------------------------------------------------------
bfl::opensnoops() {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_OPENSNOOP} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'opensnoop' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  declare -a o_args=()
  declare -a g_args=()
  local {arg,flg}=
  for arg in ${@:+"${@}"}; do
      [[ "${arg}" == "--" ]] && flg="G" && continue
      [[ "${flg}" == "G" ]] \
          && g_args[${#g_args[@]}]="${arg}" \
          || o_args[${#o_args[@]}]="${arg}"
  done

  sudo opensnoop ${o_args[*]:+"${o_args[@]}"} 2>&1 | grep --line-buffered "${g_args[@]:-}" \
      || { bfl::writelog_fail "${FUNCNAME[0]}: Failed opensnoop ${o_args[*]:+'${o_args[@]}'} | grep --line-buffered '${g_args[@]:-}'"; return 1; }

  return 0
  }
