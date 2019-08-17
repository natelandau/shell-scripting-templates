#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::transliterate().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Transliterates a string.
#
# @param string $str
#   The string to transliterate.
#
# @return string $str_transliterated
#   The transliterated string.
#
# @example
#   bfl::transliterate "_Olé Über! "
#------------------------------------------------------------------------------
bfl::transliterate() {
  bfl::verify_arg_count "$#" 1 1 || exit 1
  bfl::verify_dependencies "iconv"

  declare -r str="$1"
  declare str_transliterated

  # Enable extended pattern matching features.
  shopt -s extglob

  # Convert from UTF-8 to ASCII.
  str_transliterated=$(iconv -c -f utf8 -t ascii//TRANSLIT <<< "${str}") || bfl::die
  # Replace non-alphanumeric characters with a hyphen.
  str_transliterated=${str_transliterated//[^[:alnum:]]/-}
  # Replace two or more sequential hyphens with a single hyphen.
  str_transliterated=${str_transliterated//+(-)/-}
  # Remove leading hyphen, if any.
  str_transliterated=${str_transliterated#-}
  # Remove trailing hyphen, if any.
  str_transliterated=${str_transliterated%-}
  # Convert to lower case
  str_transliterated=${str_transliterated,,}

  printf "%s" "${str_transliterated}"
}
