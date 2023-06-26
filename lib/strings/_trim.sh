#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to Bash Strings
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::trim().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Removes leading and trailing whitespace, including blank lines, from string.
#
# The string can either be single or multi-line. In a multi-line string,
# leading and trailing whitespace is removed from every line.
#
# @param String $str
#   The string to be trimmed.
#
# @return String $str_trimmed
#   The trimmed string.
#
# @example
#   bfl::trim " foo "
#------------------------------------------------------------------------------
bfl::trim() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  # Explanation of sed commands:
  # - Remove leading whitespace from every line: s/^[[:space:]]+//
  # - Remove trailing whitespace from every line: s/[[:space:]]+$//
  # - Remove leading and trailing blank lines: /./,$ !d
  #
  # See https://tinyurl.com/yav7zw9k and https://tinyurl.com/3z8eh

  local str
  str=$(printf "%b" "$1" | sed -E 's/^[[:space:]]+// ; s/[[:space:]]+$// ; /./,$ !d') || { bfl::writelog_fail "${FUNCNAME[0]}: unable to trim whitespace."; return 1; }

  printf "%s" "$str"
  return 0
  }
