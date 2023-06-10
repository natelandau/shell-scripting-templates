#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Functions for manipulating arrays
# @file
# Defines function: bfl::merge_arrays().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Merges several arrays together. Поддержка любого количества массивов.
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
  bfl::verify_arg_count "$#" 2 999 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy [2...999]"  # Verify argument count.

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
