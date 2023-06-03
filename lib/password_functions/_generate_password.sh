#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash_functions_library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------- https://github.com/jmooring/bash-function-library.git -----------
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
  bfl::verify_arg_count "$#" 1 1 || exit 1  # Verify argument count.
  bfl::verify_dependencies "pwgen" "shuf"

  declare -r min_pswd_length=8

  bfl::is_positive_integer "$1" || bfl::die "Expected positive integer, received $1."
  [[ "$1" -lt "${min_pswd_length}"  ]] && bfl::die "Expected integer >= $min_pswd_length, received $1."

  declare -r pswd_length="$1"
  declare password length_one length_two

  length_one=$(shuf -i 1-$((pswd_length-2)) -n 1) || bfl::die
  length_two=$((pswd_length-length_one-1)) || bfl::die
  password=$(pwgen -cns "$length_one" 1)_$(pwgen -cns "$length_two" 1) || bfl::die

  printf "%s" "$password"
  }
