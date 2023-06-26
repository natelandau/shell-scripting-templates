#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to bash arrays
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::merge_arrays().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Merges several arrays together. Поддержка любого количества массивов.
#
# @param String $Array1
#   Array №1.
#
#    .......
#
# @param String $ArrayN
#   Array №N.
#
# @return String $rslt
#   Prints mergeed arrays.
#
# @example
#   newarray=($(bfl::merge_arrays "array1[@]" "array2[@]"))
#------------------------------------------------------------------------------
bfl::merge_arrays() {
  bfl::verify_arg_count "$#" 2 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2..999]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -i k=$#
  local -a arr
  local -a outputArray=()
  while ((k>0)); do
#      IFS=$'=' read -r -a arr <<< "$arg"
      arr=("${!1}")   #  https://github.com/natelandau/shell-scripting-templates
      shift
      ((k--))
      outputArray+=(${arr[@]})
  done
#  unset IFS

  printf "%s\n" "${outputArray[@]}"
  }
