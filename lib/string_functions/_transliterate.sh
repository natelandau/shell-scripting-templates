#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
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
  bfl::verify_arg_count "$#" 1 1 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 1"  # Verify argument count.
  bfl::verify_dependencies "iconv"

  local str_transliterated
  shopt -s extglob          # Enable extended pattern matching features.

  str_transliterated=$(iconv -c -f utf8 -t ascii//TRANSLIT <<< "$1") || bfl::die    # Convert from UTF-8 to ASCII.
  str_transliterated=${str_transliterated//[^[:alnum:]]/-}    # Replace non-alphanumeric characters with a hyphen.
  str_transliterated=${str_transliterated//+(-)/-}            # Replace two or more sequential hyphens with a single hyphen.
  str_transliterated=${str_transliterated#-}                  # Remove leading hyphen, if any.
  str_transliterated=${str_transliterated%-}                  # Remove trailing hyphen, if any.
  str_transliterated=${str_transliterated,,}                  # Convert to lower case

  printf "%s" "$str_transliterated"
  }
