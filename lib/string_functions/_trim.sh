#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::trim().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Removes leading and trailing whitespace, including blank lines, from string.
#
# The string can either be single or multi-line. In a multi-line string,
# leading and trailing whitespace is removed from every line.
#
# @param string $str
#   The string to be trimmed.
#
# @return string $str_trimmed
#   The trimmed string.
#
# @example
#   bfl::trim " foo "
#------------------------------------------------------------------------------
bfl::trim() {
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.

  # Explanation of sed commands:
  # - Remove leading whitespace from every line: s/^[[:space:]]+//
  # - Remove trailing whitespace from every line: s/[[:space:]]+$//
  # - Remove leading and trailing blank lines: /./,$ !d
  #
  # See https://tinyurl.com/yav7zw9k and https://tinyurl.com/3z8eh

  local str_trimmed
  str_trimmed=$(printf "%b" "$1" | sed -E 's/^[[:space:]]+// ; s/[[:space:]]+$// ; /./,$ !d') || bfl::die "Unable to trim whitespace."

  printf "%s" "$str_trimmed"
  return 0
  }
