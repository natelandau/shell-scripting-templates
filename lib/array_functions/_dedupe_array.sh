#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# --------------- https://github.com/dylanaraps/pure-bash-bible ---------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
# Functions for manipulating arrays
# @file
# Defines function: bfl::dedupe_array().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Removes duplicate array elements.
#
# @param Array $array
#   An array.
#
# @return string $deduped_array
#   Prints de-duped elements. List order may not stay the same.
#
# @example
#   bfl::mapfile -t newarray < <(bfl::dedupe_array "${array[@]}")
#------------------------------------------------------------------------------
bfl::dedupe_array() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return 1; } # Verify argument count.

  local -A tmpArray
  local -a uniqueArray
  local el
  for el in "$@"; do
      { [[ -z "$el" || -n ${tmpArray[$el]:-} ]]; } && continue
      uniqueArray+=("$el") && tmpArray[$el]=x
  done
  printf '%s\n' "${uniqueArray[@]}"
  }