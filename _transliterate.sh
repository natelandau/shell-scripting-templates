#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::transliterate().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Transliterates a string.
#
# @param string $input
#   String to bfl::transliterate (example: "_Foo Bar@  BAz").
#
# @return string $output
#   Transliterated string (example: "foo-bar-baz")
#------------------------------------------------------------------------------
bfl::transliterate() {
  bfl::verify_arg_count "$#" 1 1 || exit 1
  bfl::verify_dependencies "iconv"

  declare -r input="$1"
  declare output

  # Enable extended pattern matching features.
  shopt -s extglob

  # Convert from UTF-8 to ASCII.
  output=$(iconv -c -f utf8 -t ascii//TRANSLIT <<< "${input}") || bfl::die
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
