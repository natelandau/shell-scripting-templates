#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::string_of_char().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Repeats a string.
#
# @param string $str
#   The string to be repeated.
#
# @param int $multiplier
#   Number of times the string will be repeated.
#
# @return string $str_repeated
#   The repeated string.
#
# @example
#   bfl::string_of_char "=" "10"
#------------------------------------------------------------------------------
bfl::string_of_char() {
  bfl::verify_arg_count "$#" 2 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2"; return $BFL_ErrCode_Not_verified_args_count; }      # Verify argument count.
  bfl::verify_dependencies "perl" || { bfl::writelog_fail "${FUNCNAME[0]}: dependency perl not found" ; return $BFL_ErrCode_Not_verified_dependency; } # Verify dependencies.

  # Verify argument values.
  bfl::is_positive_integer "$2" || { bfl::writelog_fail "${FUNCNAME[0]}: $2 expected positive integer."; return 1; }

  perl -e "print '$1' x $2"
#_bar=$(printf "%0.s${barCharacter}" $(seq 1 "${_num}"))  РАБОТАЕТ!
# printf "%0.s-" {1..$y}     не работает

#                                     РАБОТАЕТ!
#  local str_repeated  # Create a string of spaces that is $multiplier long.
#  str_repeated=$(printf "%${2}s") || { bfl::writelog_fail "${FUNCNAME[0]}: str_repeated=\$(printf %${2}s)."; return 1; }
#  str_repeated=${str_repeated// /"$1"}  # Replace each space with the $str.

#  printf "%s" "$str_repeated"
  }
