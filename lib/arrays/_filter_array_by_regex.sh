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
# Defines function: bfl::filter_array_by_regex().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Determine if a regex matches an array element.  Default is case sensitive.
#   Pass -i flag to ignore case.
#
# @param String $regex_mask
#   Value to search for.
#
# @param Array $array
#   An array written as ${ARRAY[@]}.
#
# @option -i
#   Ignore case.
#
# @return Array $array
#   Prints filtered elements.
#
# @example
#  if bfl::filter_array_by_regex "VALUE" "${ARRAY[@]}"; then ...
#  if bfl::filter_array_by_regex  -i "VALUE" "${ARRAY[@]}"; then ...
#------------------------------------------------------------------------------
bfl::filter_array_by_regex() {
  bfl::verify_arg_count "$#" 2 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2, 3]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local opt
  local -i OPTIND=1
  while getopts ":iI" opt; do
      case ${opt,,} in
          i ) # shellcheck disable=SC2064
              trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
              shopt -s nocasematch                  # Use case-insensitive regex
              ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  local array_item
  local value="$1"
  shift
  for array_item in "$@"; do
      [[ "${array_item}" =~ ^$value$ ]] && printf '%s\n' "${array_item}"
  done
  }
