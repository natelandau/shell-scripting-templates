#!/usr/bin/env bash

# Library of functions related to Bash Strings
#
# @author  Michael Strache


# Prevent this library from being sourced more than once
[[ ${_GUARD_BFL_STRING:-} -eq 1 ]] && return 0 || declare -r _GUARD_BFL_STRING=1


# **************************************************************************** #
# Dependencies                                                                 #
# **************************************************************************** #


# **************************************************************************** #
# Main                                                                         #
# **************************************************************************** #

# Tests if STRING contains SUBSTRING
#
# @param String  STRING           The string to be tested
# @param String  SUBSTRING        The string to check for
#
# @return Boolean  true if SUBSTRING was found, otherwise false
function String::contains() {
  local -r STRING="${1:-}"; shift
  local -r SUBSTRING="${1:-}"; shift

  [[ "${STRING}" == *"${SUBSTRING}"* ]]
}


# Escapes all special characters in STRING
#
# @param String  STRING           String to escape values in
#
# @return String  STRING with escaped special characters
function String::escape() {
  local -r STRING="${1:-}"; shift

  if [[ -z ${STRING} ]]; then
    echo ''
    return 0
  fi

  printf -v var '%q\n' "${STRING}"
  echo "$var"
}


# Tests if STRING represents a floating point number
#
# @param String  STRING           The string to be tested
#
# @return Boolean  true if STRING is a floating point number, otherwise false
function String::is_float() {
  local -r STRING="${1:-}"; shift

  [[ ${STRING} =~ ^[-+]?[0-9]*[.,]?[0-9]+$ ]]
}


# Tests if STRING represents a hexadecimal number
#
# @param String  STRING           The string to be tested
#
# @return Boolean  true if STRING is a hexadecimal number, otherwise false
function String::is_hex_number() {
  local -r STRING="${1:-}"; shift

  [[ ${STRING} =~ ^[0-9a-fA-F]+$ ]]
}


# Tests if STRING represents an integer
#
# @param String  STRING           The string to be tested
#
# @return Boolean  true if STRING is a integer number, otherwise false
function String::is_integer() {
  local -r STRING="${1:-}"; shift

  [[ ${STRING} =~ ^[-+]?[0-9]+$ ]]
}


# Tests if STRING represents a natural number
#
# @param String  STRING           The string to be tested
#
# @return Boolean  true if STRING is a natural number, otherwise false
function String::is_natural_number() {
  local -r STRING="${1:-}"; shift

  [[ ${STRING} =~ ^[0-9]+$ ]]
}


# Tests if STRING represents a number of any kind
#
# @param String  STRING           The string to be tested
#
# @return Boolean  true if STRING is a number, otherwise false
function String::is_number() {
  local -r STRING="${1:-}"; shift

  String::is_natural_number "${STRING}" || String::is_integer "${STRING}" || String::is_float "${STRING}"
}


# Tests if STRING is a version string (e.g. 1.0.0 or 1.0.0-SNAPSHOT)
#
# @param String  STRING           The string to be tested
#
# @return Boolean  true if STRING is a version string, otherwise false
function String::is_version() {
  local -r STRING="${1:-}"; shift

  [[ ${STRING} =~ ^[[:digit:]]+(\.[[:digit:]]+){0,2}(-[[:alnum:]]+)?$ ]]
}


# Replaces each occurrence of TARGET in STRING with REPLACEMENT
#
# @param String  STRING           The string to be tested
# @param String  TARGET           The sequence of char values to be replaced
# @param String  REPLACEMENT      The replacement sequence of char values
#
# @return String  STRING with TARGET being replaced
function String::replace() {
  local -r STRING="${1:-}"; shift

  # Escaping special characters in TARGET and REPLACEMENT
  local -r TARGET="$( sed -e 's/[]\/$*.^|[]/\\&/g' <<<"${1:-}" )"; shift
  local -r REPLACEMENT="$( sed -e 's/[\/&]/\\&/g' <<<"${1:-}" )"; shift

  # Is true when either TARGET or REPLACEMENT are not specified (-> the call only has one or two parameters)
  if [[ -z ${REPLACEMENT} ]]; then
    echo "${STRING}"
  else
    sed "s/${TARGET}/${REPLACEMENT}/g" <<< "${STRING}"
  fi
}


# Returns the string representation of an array, containing all fragments of STRING splitted using REGEX
# Example: String::split "foo--bar" "-+" -> "( foo bar )"
#
# @param String  STRING           The string to be splitted
# @param String  REGEX            Delimiting regular expression
#
# @return String  String representation of an array with the splitted STRING
function String::split() {
  local -r STRING="${1:-}"; shift
  local -r REGEX="${1:-}"; shift

  if [[ -z ${REGEX} ]]; then
    echo "( ${STRING} )"
    return 0
  fi

  # The MacOS version does not support the '-r' option but instead has the '-E' option doing the same
  if sed -r "s/-/ /" <<< "" &>/dev/null; then
    local -r SED_OPTION="-r"
  else
    local -r SED_OPTION="-E"
  fi

  echo "( $( sed ${SED_OPTION} "s/${REGEX}/ /g" <<< "${STRING}" ) )"
}


# Tests if STRING starts with PREFIX
#
# @param String  STRING           The string to be tested
# @param String  PREFIX           The prefix
#
# @return Boolean  true if STRING starts with PREFIX, otherwise false
function String::starts_with() {
  local -r STRING="${1:-}"; shift
  local -r PREFIX="${1:-}"; shift

  [[ ${STRING} =~ ^${PREFIX}.* ]]
}


# Converts STRING to lower case
#
# @param String  STRING           The string to be converted
#
# @return String  Lower case representation of STRING
function String::to_lowercase() {
  local -r STRING="${1:-}"; shift

  echo "${STRING,,}"
}


# Converts STRING to upper case
#
# @param String  STRING           The string to be converted
#
# @return String  Upper case representation of STRING
function String::to_uppercase() {
  local -r STRING="${1:-}"; shift

  echo "${STRING^^}"
}
