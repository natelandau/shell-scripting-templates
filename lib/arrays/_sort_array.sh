#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------ https://github.com/labbots/bash-utility ------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to bash arrays
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::sort_array().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Sorts an array from lowest to highest (0-9 a-z).
#
# @param Array $Array or space separated items to be joined
#   Array.
#
# @option --sort_order  Integer  $val
#   0 - sort, 1 - reverse sort.
#
# @return String $rslt
#   Prints sorted array.
#
# @example
#   input=("c" "b" "4" "1" "2" "3" "a")
#   bfl::sort_array "${input[@]}"
#           1 2 3 4 a b c
#------------------------------------------------------------------------------
bfl::sort_array() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local b=false
  local el
  local -a arr=( $@ )
  for el in ${arr[@]}; do
      if [[ "$el" =~ '--reverse' ]]; then
          b=true
          arr=( "${arr[@]/$el}" )     # https://stackoverflow.com/questions/16860877/remove-an-element-from-a-bash-array
          break
      fi
  done

  local -a sortedArray
  if ! $b; then
      mapfile -t sortedArray < <(printf '%s\n' "${arr[@]}" | sort)
  else
      mapfile -t sortedArray < <(printf '%s\n' "${arr[@]}" | sort -r)
  fi

  printf "%s\n" "${sortedArray[@]}"
  }
