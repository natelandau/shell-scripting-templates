#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::generate_password().
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
lib::generate_password() {
  lib::validate_arg_count "$#" 1 1 || return 1
  declare -r password_length="$1"
  declare length_one
  declare length_two
  declare password

  lib::verify_dependencies "pwgen" "shuf" || return 1

  if lib::is_empty "${password_length}"; then
    lib::err "Error: the password length was not specified."
    return 1
  fi

  if ! lib::is_integer "${password_length}"; then
    lib::err "Error: the password length must be an integer."
    return 1
  fi

  if [[ "${password_length}" -lt "8" ]]; then
    lib::err "Error: the password length must be 8 or more characters."
    return 1
  fi

  length_one=$(shuf -i 1-$((password_length-2)) -n 1)
  length_two=$((password_length-length_one-1))
  password=$(pwgen -cns "$length_one" 1)_$(pwgen -cns "$length_two" 1)

  printf "%s" "${password}"
}
