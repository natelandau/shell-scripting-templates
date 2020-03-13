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

  declare -r target="$1"
  declare -ar list="($2)"

  declare nearest

  declare -r regex="^(-{0,1}[0-9]+\s*)+$"
  declare abs_diff
  declare diff
  declare item
  declare table

  bfl::is_integer "${target}" \
    || bfl::die "Expected integer, received ${target}."

  if ! [[ "${list[*]}" =~ ${regex} ]]; then
    bfl::die "Expected list of integers, received ${list[*]}."
  fi

  for item in "${list[@]}"; do
    diff=$((target-item)) || bfl::die
    abs_diff="${diff/-/}"
    table+="${item} ${abs_diff}\\n"
  done

  # Remove final line feed from $table.
  table=${table::-2}

  nearest=$(echo -e "${table}" | sort -n -k2 | head -n1 | cut -f1 -d " ") || bfl::die
  printf "%s" "${nearest}"
}
