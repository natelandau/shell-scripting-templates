#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::find_nearest_integer().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Finds the nearest integer to a target integer from a list of integers.
#
# Example usage:
#
#   lib::find_nearest_integer "4" "0 3 6 9 12"
#
# @param string $target
#   The target integer.
# @param string $list
#   List of integers.
# @return string $nearest
#   Integer in list that is nearest to the target.
#------------------------------------------------------------------------------
lib::find_nearest_integer() {
  lib::validate_arg_count "$#" 2 2 || exit 1

  if ! lib::is_integer "$1"; then
    lib::die "Error: expected integer, received $1"
  fi

  if lib::is_empty "$2"; then
    lib::die "Error: expected list, received empty string"
  fi

  declare -r target="$1"
  declare -ar list="($2)"
  declare item
  declare table
  declare nearest

  for item in "${list[@]}"; do
    if ! lib::is_integer "${item}"; then
      lib::die "Error: expected integer, received ${item}"
    fi
    diff=$((target-item)) || lib::die
    abs_diff=${diff/-/}
    table+="${item} ${abs_diff}\\n"
  done

  # Remove final line feed from $table.
  table=${table::-2}

  nearest=$(echo -e "${table}" | sort -n -k2 | head -n1 | cut -f1 -d " ") || lib::die
  printf "%s" "${nearest}"
}
