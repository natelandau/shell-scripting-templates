#!/usr/bin/env bats
#shellcheck disable

# Unittests for the functions in lib/numbers
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #
[[ $_GUARD_BFL_autoload -ne 1 ]] && . /etc/getConsts && . "$BASH_FUNCTION_LIBRARY" # подключаем внешнюю "библиотеку"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #


# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# bfl::is_float                                                                #
# ---------------------------------------------------------------------------- #

@test "bfl::is_float -> If STRING is a floating point number, the function should return 0, otherwise 1" {
  run bfl::is_float "1"
  [ "${status}" -eq 0 ]

  run bfl::is_float "0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "+1"
  [ "${status}" -eq 0 ]

  run bfl::is_float "-1"
  [ "${status}" -eq 0 ]

  run bfl::is_float "1.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "0.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "-1.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float "+1.0"
  [ "${status}" -eq 0 ]

  run bfl::is_float ""
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------- #
# bfl::is_hex_number                                                           #
# ---------------------------------------------------------------------------- #

@test "bfl::is_hex_number -> If STRING is a hexadecimal, the function should return 0, otherwise 1" {
  run bfl::is_hex_number "1"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "0"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "a"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "A"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "1a"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "a1"
  [ "${status}" -eq 0 ]

  run bfl::is_hex_number "+1"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number "-1"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number "1.0"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number "g"
  [ "${status}" -eq 1 ]

  run bfl::is_hex_number ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# bfl::is_integer                                                              #
# ---------------------------------------------------------------------------- #

@test "bfl::is_integer -> If STRING is an integer, the function should return 0, otherwise 1" {
  run bfl::is_integer "1"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "0"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "+1"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "-1"
  [ "${status}" -eq 0 ]

  run bfl::is_integer "1.0"
  [ "${status}" -eq 1 ]

  run bfl::is_integer ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# bfl::is_natural_number                                                    #
# ---------------------------------------------------------------------------- #

@test "bfl::is_natural_number -> If STRING is a natural number, the function should return 0, otherwise 1" {
  run bfl::is_natural_number "1"
  [ "${status}" -eq 0 ]

  run bfl::is_natural_number "0"
  [ "${status}" -eq 0 ]

  run bfl::is_natural_number "-1"
  [ "${status}" -eq 1 ]

  run bfl::is_natural_number "1.0"
  [ "${status}" -eq 1 ]

  run bfl::is_natural_number ""
  [ "${status}" -eq 1 ]
}
