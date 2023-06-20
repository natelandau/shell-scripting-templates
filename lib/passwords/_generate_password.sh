#!/usr/bin/env bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|') || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------- https://github.com/jmooring/bash-function-library.git -----------
#
# Library of functions related to password abd cache generating, files encrypting
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::generate_password().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Generates a random password.
#
# Password characteristics:
# - At least one lowercase letter
# - At least one uppercase letter
# - At least one digit
# - One underscore placed randomly in the middle.
# - Minimum length of 8
#
# The underscore placed randomly in the middle ensures that the password will
# have at least one special character. The underscore is probably the most
# benign special character (i.e., it won't break quoted strings, doesn't
# contain escape sequences, etc.).
#
# @param int $pswd_length
#   The length of the desired password.
#
# @return string $password
#   A random password
#
# @example
#   bfl::generate_password "16"
#------------------------------------------------------------------------------
bfl::generate_password() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1"; return $BFL_ErrCode_Not_verified_args_count; }                       # Verify argument count.
  bfl::verify_dependencies "pwgen" "shuf" || { bfl::writelog_fail "${FUNCNAME[0]}: dependencies pegen shuf not found"; return $BFL_ErrCode_Not_verified_dependency; }  # Verify dependencies.

  declare -r min_pswd_length=8

  bfl::is_positive_integer "$1"   || { bfl::writelog_fail "${FUNCNAME[0]}: Expected password length ($1) to be positive integer."; return $BFL_ErrCode_Not_verified_arg_values; }
  [[ $1 -lt ${min_pswd_length} ]] && { bfl::writelog_fail "${FUNCNAME[0]}: Expected password length ($1) >= $min_pswd_length.";    return $BFL_ErrCode_Not_verified_arg_values; }

  declare -r pswd_length="$1"
  declare password length_one length_two

  length_one=$(shuf -i 1-$((pswd_length-2)) -n 1) || { bfl::writelog_fail "${FUNCNAME[0]}: length_one = \$(shuf -i 1-($pswd_length-2) -n 1)"; return 1; }
  length_two=$((pswd_length-length_one-1))        || { bfl::writelog_fail "${FUNCNAME[0]}: length_two = $pswd_length - $length_one - 1";      return 1; }
  password=$(pwgen -cns "$length_one" 1)_$(pwgen -cns "$length_two" 1) || { bfl::writelog_fail "${FUNCNAME[0]}: cannot generate password";    return 1; }

  printf "%s" "$password"
  }
