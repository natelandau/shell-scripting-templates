#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to bash arrays
#
# @author  Alexei Kharchev
#
# @file
# Defines function: bfl::array_synchro_bubble_sort().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Sorts array1 and array2 by values in array2 descending.
#
# @param Array $string_array
#   The array with strings.
#
# @param Array $rating_array
#   The array with integer values.
#
# @return String $result
#   array1;array2   with ; as delimeter
#
# @example
#   bfl::array_synchro_bubble_sort string_array1[@] rating_array[@]
#------------------------------------------------------------------------------
bfl::array_synchro_bubble_sort() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Verify argument values.
  local -a string_array=( $1 )
  local -i i=${#string_array[@]}
  [[ $i -gt 0 ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: string array is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  local -a rating_array=( $2 )
  local -i k=${#rating_array[@]}
  [[ $k -gt 0 ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: rating array is empty!"; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ $i -eq $k ]] || { bfl::writelog_fail "${FUNCNAME[0]}: lengths of string and rating arrays are not equal: $i ≠ $k"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -i j t max
  local el; max=$k
  while ((k > 0)); do
      for ((i = 0; i < k; i++)); do
          ((j=i+1))
          if [ $j -ne $max -a ${rating_array[$i]} < ${rating_array[$j]} ]; then # then #array will not be out of bound "$(($max-1))"
              t=${rating_array[$i]}
              rating_array[$i]=${rating_array[$j]}
              rating_array[$j]=$t

              el=${string_array[$i]}
              string_array[$i]=${string_array[$j]}
              string_array[$j]=$el
          fi
      done
      ((k--))
  done

  echo "${string_array[*]};${rating_array[*]}"
  return 0
  }
