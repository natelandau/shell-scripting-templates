#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to Bash Strings
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::transliterate().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Transliterates a string.
#
# @param String $str
#   The string to transliterate.
#
# @return String $str
#   The transliterated string.
#
# @example
#   bfl::transliterate "_Olé Über! "
#------------------------------------------------------------------------------
bfl::transliterate() {
  bfl::verify_arg_count "$#" 1 1 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 1";        return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_ICONV} -eq 1 ]]  || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'iconv' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local str
  shopt -s extglob          # Enable extended pattern matching features.

  # Convert from UTF-8 to ASCII.
  str=$(iconv -c -f utf8 -t ascii//TRANSLIT <<< "$1") || { bfl::writelog_fail "${FUNCNAME[0]}: str=\$(iconv -c -f utf8 -t ascii//TRANSLIT <<< $1)"; return 1; }
  str=${str//[^[:alnum:]]/-}    # Replace non-alphanumeric characters with a hyphen.
  str=${str//+(-)/-}            # Replace two or more sequential hyphens with a single hyphen.
  str=${str#-}                  # Remove leading hyphen, if any.
  str=${str%-}                  # Remove trailing hyphen, if any.
  str=${str,,}                  # Convert to lower case

  printf "%s" "$str"
  }
