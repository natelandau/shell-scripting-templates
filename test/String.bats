#!/usr/bin/env bats

# Unittests for the functions in String.sh
#
# The unit tests in this script are written using the BATS framework.
# See: https://github.com/sstephenson/bats


# **************************************************************************** #
# Imports                                                                      #
# **************************************************************************** #

source "${BATS_TEST_DIRNAME}/../lib/String.sh"


# **************************************************************************** #
# Init                                                                         #
# **************************************************************************** #

# **************************************************************************** #
# Test Casses                                                                  #
# **************************************************************************** #

# ---------------------------------------------------------------------------- #
# String::contains                                                             #
# ---------------------------------------------------------------------------- #

@test "String::contains -> If STRING contains SUBSTRING, the function should return 0, otherwise 1" {
  run String::contains "abcd" "ab"
  [ "${status}" -eq 0 ]

  run String::contains "abcd" "bc"
  [ "${status}" -eq 0 ]

  run String::contains "abcd" "cd"
  [ "${status}" -eq 0 ]

  # The string contains itself
  run String::contains "abcd" "abcd"
  [ "${status}" -eq 0 ]

  # Each string contains the empty string
  run String::contains "abcd" ""
  [ "${status}" -eq 0 ]

  # The empty string contains the empty string
  run String::contains "" ""
  [ "${status}" -eq 0 ]

  # If no SUBSTRING is specified, an empty string is assumed
  run String::contains "abcd"
  [ "${status}" -eq 0 ]

  run String::contains "abcd" "e"
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# String::escape                                                               #
# ---------------------------------------------------------------------------- #

@test "String::escape -> Should return STRING with all special characters escaped" {
  run String::escape 'foo'
  [ "${output}" == 'foo' ]

  run String::escape 'foo\'
  [ "${output}" == 'foo\\' ]

  run String::escape 'f\$oo'
  [ "${output}" == 'f\\\$oo' ]

  run String::escape ''
  [ "${output}" == '' ]
}


# ---------------------------------------------------------------------------- #
# String::is_float                                                             #
# ---------------------------------------------------------------------------- #

@test "String::is_float -> If STRING is a floating point number, the function should return 0, otherwise 1" {
  run String::is_float "1"
  [ "${status}" -eq 0 ]

  run String::is_float "0"
  [ "${status}" -eq 0 ]

  run String::is_float "+1"
  [ "${status}" -eq 0 ]

  run String::is_float "-1"
  [ "${status}" -eq 0 ]

  run String::is_float "1.0"
  [ "${status}" -eq 0 ]

  run String::is_float "0.0"
  [ "${status}" -eq 0 ]

  run String::is_float "-1.0"
  [ "${status}" -eq 0 ]

  run String::is_float "+1.0"
  [ "${status}" -eq 0 ]

  run String::is_float ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# String::is_hex_number                                                        #
# ---------------------------------------------------------------------------- #

@test "String::is_hex_number -> If STRING is a hexadecimal, the function should return 0, otherwise 1" {
  run String::is_hex_number "1"
  [ "${status}" -eq 0 ]

  run String::is_hex_number "0"
  [ "${status}" -eq 0 ]

  run String::is_hex_number "a"
  [ "${status}" -eq 0 ]

  run String::is_hex_number "A"
  [ "${status}" -eq 0 ]

  run String::is_hex_number "1a"
  [ "${status}" -eq 0 ]

  run String::is_hex_number "a1"
  [ "${status}" -eq 0 ]

  run String::is_hex_number "+1"
  [ "${status}" -eq 1 ]

  run String::is_hex_number "-1"
  [ "${status}" -eq 1 ]

  run String::is_hex_number "1.0"
  [ "${status}" -eq 1 ]

  run String::is_hex_number "g"
  [ "${status}" -eq 1 ]

  run String::is_hex_number ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# String::is_integer                                                           #
# ---------------------------------------------------------------------------- #

@test "String::is_integer -> If STRING is an integer, the function should return 0, otherwise 1" {
  run String::is_integer "1"
  [ "${status}" -eq 0 ]

  run String::is_integer "0"
  [ "${status}" -eq 0 ]

  run String::is_integer "+1"
  [ "${status}" -eq 0 ]

  run String::is_integer "-1"
  [ "${status}" -eq 0 ]

  run String::is_integer "1.0"
  [ "${status}" -eq 1 ]

  run String::is_integer ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# String::is_natural_number                                                    #
# ---------------------------------------------------------------------------- #

@test "String::is_natural_number -> If STRING is a natural number, the function should return 0, otherwise 1" {
  run String::is_natural_number "1"
  [ "${status}" -eq 0 ]

  run String::is_natural_number "0"
  [ "${status}" -eq 0 ]

  run String::is_natural_number "-1"
  [ "${status}" -eq 1 ]

  run String::is_natural_number "1.0"
  [ "${status}" -eq 1 ]

  run String::is_natural_number ""
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# String::is_version                                                           #
# ---------------------------------------------------------------------------- #

@test "String::is_version -> Should return 0, when the STRING matches the pattern 'major.minor.bugfix-suffix'" {
  # Only major component
  run String::is_version "1"
  [ "${status}" -eq 0 ]

  # major and minor components
  run String::is_version "1.0"
  [ "${status}" -eq 0 ]

  # major, minor and bugfix components
  run String::is_version "1.0.0"
  [ "${status}" -eq 0 ]

  # major, minor, bugfx and suffix component
  run String::is_version "1.0.0-SNAPSHOT"
  [ "${status}" -eq 0 ]
}

@test "String::is_version -> Should return 1, when the STRING does not match the pattern 'major.minor.bugfix-suffix'" {
  # major component does not match '[[:digit:]]
  run String::is_version "1a"
  [ "${status}" -eq 1 ]

  # minor component does not match '[[:digit:]]
  run String::is_version "1.0a"
  [ "${status}" -eq 1 ]

  # bugfix component does not match '[[:digit:]]'
  run String::is_version "1.0.0a"
  [ "${status}" -eq 1 ]

  # has more than three version-components
  run String::is_version "1.0.0.0"
  [ "${status}" -eq 1 ]

  # sufix does not match '-[[:alnum:]]'
  run String::is_version "1.0.0-SNAPSHOT-A"
  [ "${status}" -eq 1 ]
}


# ---------------------------------------------------------------------------- #
# String::replace                                                              #
# ---------------------------------------------------------------------------- #

@test "String::replace -> Should return STRING with each occurence of TARGET replaced with REPLACEMENT" {
  # String with a single occurence
  run String::replace "foo-bar" "-" "#"
  [ "${output}" == "foo#bar" ]

  # String with multiple occurences
  run String::replace "foo-bar" "o" "#"
  [ "${output}" == "f##-bar" ]

  # String with no occurences
  run String::replace "foo-bar" "#" "#"
  [ "${output}" == "foo-bar" ]

  # Match multiple chars
  run String::replace "foo-bar" "oo" "#"
  [ "${output}" == "f#-bar" ]

  # Match one char, replace with multiple chars
  run String::replace "foo-bar" "-" "##"
  [ "${output}" == "foo##bar" ]
}

@test "String::replace -> Should return the STRING if REPLACEMENT or TARGET were not specified" {
  # String with a single occurence
  run String::replace "foo-bar" "-"
  [ "${output}" == "foo-bar" ]

  # String with a single occurence
  run String::replace "foo-bar"
  [ "${output}" == "foo-bar" ]
}

@test "String::replace -> Should return an empty string if STRING was not specified" {
  # String with a single occurence
  run String::replace
  [ "${output}" == "" ]
}


# ---------------------------------------------------------------------------- #
# String::split                                                                #
# ---------------------------------------------------------------------------- #

@test "String::split -> Should return the string representation of an array, containing STRING splittet into its elements using REGEX" {
  # String separated by a single char
  run String::split "foo,bar" ","
  [ "${output}" == "( foo bar )" ]

  # String separated by a multiple chars
  run String::split "foo, bar" ", "
  [ "${output}" == "( foo bar )" ]

  # String separated by a a regex
  run String::split "foo--bar" "-+"
  [ "${output}" == "( foo bar )" ]

  # No separator
  run String::split "foo,bar"
  [ "${output}" == "( foo,bar )" ]

  # No argument
  run String::split
  [ "${output}" == "(  )" ]
}


# ---------------------------------------------------------------------------- #
# String::starts_with                                                          #
# ---------------------------------------------------------------------------- #

@test "String::starts_with -> If STRING starts with PREFIX, the function should return 0, otherwise 1" {
  # String completely upper case
  run String::starts_with "foobar" "foo"
  [ "${status}" -eq 0 ]

  # String partly upper case
  run String::starts_with "foobar" "FOO"
  [ "${status}" -eq 1 ]

  # String partly upper case
  run String::starts_with "foobar" "fooo"
  [ "${status}" -eq 1 ]

    # String completely lower case
  run String::starts_with "foobar"
  [ "${status}" -eq 0 ]

  # No argument
  run String::starts_with
  [ "${status}" -eq 0 ]
}


# ---------------------------------------------------------------------------- #
# String::to_lowercase                                                         #
# ---------------------------------------------------------------------------- #

@test "String::to_lowercase -> Should return STRING converted to lower case" {
  # String completely upper case
  run String::to_lowercase "FOOBAR"
  [ "${output}" == "foobar" ]

  # String partly upper case
  run String::to_lowercase "FOObar"
  [ "${output}" == "foobar" ]

    # String completely lower case
  run String::to_lowercase "foobar"
  [ "${output}" == "foobar" ]

  # No argument
  run String::to_lowercase
  [ "${output}" == "" ]
}


# ---------------------------------------------------------------------------- #
# String::to_uppercase                                                         #
# ---------------------------------------------------------------------------- #

@test "String::to_uppercase -> Should return STRING converted to upper case" {
  # String completely upper case
  run String::to_uppercase "foobar"
  [ "${output}" == "FOOBAR" ]

  # String partly upper case
  run String::to_uppercase "FOObar"
  [ "${output}" == "FOOBAR" ]

    # String completely lower case
  run String::to_uppercase "FOOBAR"
  [ "${output}" == "FOOBAR" ]

  # No argument
  run String::to_uppercase
  [ "${output}" == "" ]
}
