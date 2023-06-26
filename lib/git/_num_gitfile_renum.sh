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
# Defines function: bfl::num_gitfile_renum().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @example
#   bfl::num_gitfile_renum 5 ....
#------------------------------------------------------------------------------
bfl::num_gitfile_renum()  {
  bfl::verify_arg_count "$#" 2 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
#  [ -n "${1}" -a "${#}" -gt 1 ] || return 1  То же самое
  [[ ${_BFL_HAS_GIT} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'git' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  # Verify argument values.
  bfl::is_integer "$1" || { bfl::writelog_fail "${FUNCNAME[0]}: '$1' is has no integer type"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local f file_d file_n file_b J
  local -i i diff
  local -i diff="$1"; shift
  local -a files=("${@}")

  for f in "${files[@]}"; do
      file_d="${f%/*}"
      [[ "${file_d}" == "$f" ]] && file_d=

      file_n="${f##*/}"
      i="${file_n%%_*}"
      file_b="${file_n#*_}"

      printf -v J %02d "$(( i + diff ))"
      command git mv -vk "$f" "${file_d:+${file_d}/}${J}_${file_b}" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed command git mv -vk '$f' '${file_d:+${file_d}/}${J}_${file_b}'"; return 1; }
  done

  return 0
  }
