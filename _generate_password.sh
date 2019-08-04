#!/usr/bin/env bash

#------------------------------------------------------------------------------
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
# benign special character (i.e., it won't break quoted strings, doesn't contain
# escape sequences, etc.).
#
# @param integer $password_length
#   The length of the desired password.
#
# @return string $password
#   A random password
#------------------------------------------------------------------------------
bfl::generate_password() {
  bfl::verify_arg_count "$#" 1 1 || exit 1
  bfl::verify_dependencies "pwgen" "shuf"

  declare -r password_length="$1"
  declare length_one
  declare length_two
  declare password

  if bfl::is_empty "${password_length}"; then
    bfl::die "Error: the password length was not specified."
  fi

  if ! bfl::is_integer "${password_length}"; then
    bfl::die "Error: the password length must be an integer."
  fi

  if [[ "${password_length}" -lt "8" ]]; then
    bfl::die "Error: the password length must be 8 or more characters."
  fi

  length_one=$(shuf -i 1-$((password_length-2)) -n 1) || bfl::die
  length_two=$((password_length-length_one-1)) || bfl::die
  password=$(pwgen -cns "$length_one" 1)_$(pwgen -cns "$length_two" 1) || bfl::die

  printf "%s" "${password}"
}
