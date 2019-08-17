#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
  bfl::verify_arg_count "$#" 2 2 || exit 1

  if ! bfl::is_integer "$1"; then
    bfl::die "Error: expected integer, received $1"
  fi

  if bfl::is_empty "$2"; then
    bfl::die "Error: expected list, received empty string"
  fi

  declare -r target="$1"
  declare -ar list="($2)"
  declare item
  declare table
  declare nearest

  for item in "${list[@]}"; do
    if ! bfl::is_integer "${item}"; then
      bfl::die "Error: expected integer, received ${item}"
    fi
    diff=$((target-item)) || bfl::die
    abs_diff=${diff/-/}
    table+="${item} ${abs_diff}\\n"
  done

  # Remove final line feed from $table.
  table=${table::-2}

  nearest=$(echo -e "${table}" | sort -n -k2 | head -n1 | cut -f1 -d " ") || bfl::die
  printf "%s" "${nearest}"
}
