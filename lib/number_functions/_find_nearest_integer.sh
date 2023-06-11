#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::find_nearest_integer().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Finds the nearest integer to a target integer from a list of integers.
#
# @param string $target
#   The target integer.
# @param string $list
#   A list of integers.
#
# @return string $nearest
#   Integer in list that is nearest to the target.
#
# @example
#   bfl::find_nearest_integer "4" "0 3 6 9 12"
#------------------------------------------------------------------------------
bfl::find_nearest_integer() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return 1; } # Verify argument count.

  local -r target="$1"
  declare -ar list="($2)"

  local nearest abs_diff diff item table

  bfl::is_integer "$target" || { bfl::writelog_fail "${FUNCNAME[0]}: '$target' expected to be integer."; return 1; }

  ! [[ "${list[*]}" =~ ^(-{0,1}[0-9]+\s*)+$ ]] && bfl::writelog_fail "${FUNCNAME[0]}: '${list[*]}' expected to be list of integers." && return 1

  for item in "${list[@]}"; do
    diff=$((target-item)) || { bfl::writelog_fail "${FUNCNAME[0]}: diff = '$target'-'$item'."; return 1; }
    abs_diff="${diff/-/}"
    table+="$item $abs_diff\\n"
  done

  # Remove final line feed from $table.
  table=${table::-2}

  nearest=$(echo -e "$table" | sort -n -k2 | head -n1 | cut -f1 -d " ") || { bfl::writelog_fail "${FUNCNAME[0]}: nearest = \$(echo -e '$table' | sort -n -k2 | head -n1 | cut -f1 -d ' ')"; return 1; }
  printf "%s" "$nearest"

  return 0
  }