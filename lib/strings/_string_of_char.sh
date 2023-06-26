#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Library of functions related to Bash Strings
#
#
#
# @file
# Defines function: bfl::string_of_char().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Repeats a string.
#
# @param String $str
#   The string to be repeated.
#
# @param Integer $multiplier
#   Number of times the string will be repeated.
#
# @return String $str_repeated
#   The repeated string.
#
# @example
#   bfl::string_of_char "=" "10"
#------------------------------------------------------------------------------
bfl::string_of_char() {
  bfl::verify_arg_count "$#" 2 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return ${BFL_ErrCode_Not_verified_args_count}; }      # Verify argument count.

  # Verify argument values.
  bfl::is_positive_integer "$2" || { bfl::writelog_fail "${FUNCNAME[0]}: $2 expected positive integer."; return 1; }

  if bfl::command_exists 'perl'; then
      perl -e "print '$1' x $2"
  else
      printf "%0.s${barCharacter}" $(seq 1 "${_num}")
#     printf "%0.s-" {1..$y}     не работает
  fi

  return 0

#                                     также РАБОТАЕТ!
#  local str_repeated  # Create a string of spaces that is $multiplier long.
#  str_repeated=$(printf "%${2}s") || { bfl::writelog_fail "${FUNCNAME[0]}: str_repeated=\$(printf %${2}s)."; return 1; }
#  str_repeated=${str_repeated// /"$1"}  # Replace each space with the $str.

#  printf "%s" "$str_repeated"
  }
