#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  A. River
#
# @file
# Defines function: bfl::num_file_renum().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @option String  'v'
#   Input 'v' to show verbose output.
#
# @param String $diff
#   ..............................
#
# @param String $args
#   arguments
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   bfl::num_file_renum "file.zip"
#------------------------------------------------------------------------------
bfl::num_file_renum() {
  bfl::verify_arg_count "$#" 2 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
#   То же самое
#  [ -n "${1}" -a "${#}" -gt 1 ] || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 999]"; return 1; } # Verify argument count.

  local diff="${1}"; shift
  local -a files=("${@}")

  local f d file_n file_b I J
  for f in "${files[@]}"; do
      d="${f%/*}"
      [[ "${d}" == "${f}" ]] && d=

      file_n="${f##*/}"
      I="${file_n%%_*}"
      file_b="${file_n#*_}"

      if [[ $BASH_INTERACTIVE == true ]]; then
          printf -v J %02d "$(( I + diff ))" ||  { bfl::writelog_fail "${FUNCNAME[0]}: Failed printf -v J %02d \$(( I + diff ))"; return 1; }
          command mv -vi "${f}" "${d:+${d}/}${J}_${file_b}" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed command mv -vi '$f' '${d:+$d/}$J_${file_b}'"; return 1; }
      else
          printf J %02d "$(( I + diff ))"    ||  { bfl::writelog_fail "${FUNCNAME[0]}: printf J %02d \$(( I + diff ))."; return 1; }
          command mv -i "${f}" "${d:+${d}/}${J}_${file_b}" || { bfl::writelog_fail "${FUNCNAME[0]}: Failed command mv -i '$f' '${d:+$d/}$J_${file_b}'"; return 1; }
      fi
  done

  return 0
  }
