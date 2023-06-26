#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of internal library functions
#
# @author  A. River
#
# @file
# Defines function: bfl::declare_vars().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ........................
#
# @param String $args
#   Variables list.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::declare_vars
#------------------------------------------------------------------------------
bfl::declare_vars() {
#  bfl::verify_arg_count "$#" 1 999  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  local ___declare_vars_vars=(
  ___declare_vars_I
  ___declare_vars_4eval
  ___declare_vars_tmps
  ___declare_vars_tmp
  ___declare_vars_char
  ___declare_vars_nams
  ___declare_vars_nam
  ___declare_vars_opt
  ___declare_vars_flg_array
  ___declare_vars_vals
  ___declare_vars_val
  ___declare_vars_dec
  ___declare_vars_excludes
  )
  local ${___declare_vars_vars[*]}

  ___declare_vars_nams=()
  ___declare_vars_excludes=( ${!___DECLARE_VARS_*} ${!___declare_vars_*} )

  for ___declare_vars_tmp in "${@}"; do
      if [[ "${___declare_vars_tmp}" == -* ]]; then
          ___declare_vars_excludes[${#___declare_vars_excludes[@]}]="${___declare_vars_tmp#-}"
      else
          ___declare_vars_nams[${#___declare_vars_nams[@]}]="${___declare_vars_tmp#+}"
      fi
  done

  ___declare_vars_tmp=
  if [[ "${#___declare_vars_nams[@]}" -eq 0 ]]; then
      for ___declare_vars_char in {A..Z} _ {a..z}; do
          printf -v ___declare_vars_4eval '___declare_vars_tmps=( ${!%s*} )' "${___declare_vars_char}"
          eval "${___declare_vars_4eval}"

          [[ "${?}" -eq 0 && "${#___declare_vars_tmps[@]}" -gt 0 ]] || continue
          ___declare_vars_nams=( "${___declare_vars_nams[@]}" "${___declare_vars_tmps[@]}" )
      done
      ___declare_vars_tmps=()
  fi

  for ___declare_vars_nam in "${___declare_vars_nams[@]}"; do
      [[ " ${___declare_vars_excludes[*]} " != *" ${___declare_vars_nam} "* ]] || continue

      ___declare_vars_opt="$( declare -p "${___declare_vars_nam}" )"
      ___declare_vars_opt="${___declare_vars_opt#declare }"
      ___declare_vars_opt="${___declare_vars_opt%% *}"

      printf -v ___declare_vars_dec '%4s %s=' "${___declare_vars_opt}" "${___declare_vars_nam}"
      [[ "${___declare_vars_opt}" == *a* ]] && ___declare_vars_flg_array=1 || ___declare_vars_flg_array=0
      printf -v ___declare_vars_4eval '___declare_vars_vals=( "${%s[@]}" )' "${___declare_vars_nam}"
      eval "${___declare_vars_4eval}"

      if [[ "${#___declare_vars_vals[@]}" -eq 0 ]]; then
          printf -v ___declare_vars_dec '%s()' "${___declare_vars_dec}"
      else
          [[ "${___declare_vars_flg_array}" -eq 1 ]] && printf -v ___declare_vars_dec '%s(' "${___declare_vars_dec}"

          for (( ___declare_vars_I=0; ___declare_vars_I<${#___declare_vars_vals[@]}; ___declare_vars_I++ )); do
              printf -v ___declare_vars_val '%q' "${___declare_vars_vals[${___declare_vars_I}]}"
              if [[ "${___declare_vars_val}" != "$'"* ]] && [[ "${___declare_vars_val}" == *\\* ]]; then
                  printf -v ___declare_vars_val '%s' "${___declare_vars_vals[${___declare_vars_I}]}"
                  printf -v ___declare_vars_val '%s' "$( declare -p ___declare_vars_val )"
                  ___declare_vars_val="${___declare_vars_val#*=}"
              fi
              [[ "${___declare_vars_flg_array}" -eq 1 ]] && printf -v ___declare_vars_val ' [%s]=%s' "${___declare_vars_I}" "${___declare_vars_val}"
              printf -v ___declare_vars_dec '%s%s' "${___declare_vars_dec}" "${___declare_vars_val}"
          done

          [[ "${___declare_vars_flg_array}" -eq 1 ]] && printf -v ___declare_vars_dec '%s )' "${___declare_vars_dec}"
      fi

      printf 'declare %s\n' "${___declare_vars_dec}"
  done

  return 0
  }
