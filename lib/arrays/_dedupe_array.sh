#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# --------------- https://github.com/dylanaraps/pure-bash-bible ---------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to bash arrays
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::dedupe_array().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Removes duplicate array elements.
#
# @param Array $array
#   An array.
#
# @return String $deduped_array
#   Prints de-duped elements. List order may not stay the same.
#
# @example
#   bfl::mapfile -t newarray < <(bfl::dedupe_array "${array[@]}")
#------------------------------------------------------------------------------
bfl::dedupe_array() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local -A tmpArray
  local -a uniqueArray
  local el
  for el in "$@"; do
      { [[ -z "$el" || -n ${tmpArray[$el]:-} ]]; } && continue
      uniqueArray+=("$el") && tmpArray[$el]=x
  done
  printf '%s\n' "${uniqueArray[@]}"
  }
