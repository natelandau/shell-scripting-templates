#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: lib::transliterate().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Transliterates a string.
#
# @param string $input
#   String to lib::transliterate (example: "_Foo Bar@  BAz").
#
# @return string $output
#   Transliterated string (example: "foo-bar-baz")
#------------------------------------------------------------------------------
lib::transliterate() {
  lib::validate_arg_count "$#" 1 1 || return 1
  declare -r input="$1"
  declare output

  lib::verify_dependencies "iconv" || return 1

  # Enable extended pattern matching features.
  shopt -s extglob

  # Convert from UTF-8 to ASCII.
  output=$(iconv -c -f utf8 -t ascii//TRANSLIT <<< "${input}")
  # Replace non-alphanumeric characters with a hyphen.
  output=${output//[^[:alnum:]]/-}
  # Replace two or more sequential hyphens with a single hyphen.
  output=${output//+(-)/-}
  # Remove leading hyphen, if any.
  output=${output#-}
  # Remove trailing hyphen, if any.
  output=${output%-}
  # Convert to lower case
  output=${output,,}

  printf "%s" "${output}"
}
