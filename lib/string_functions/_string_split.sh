#!/usr/bin/env bash

# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to Bash Strings
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::string_split().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Returns the string representation of an array, containing all fragments of STRING splitted using REGEX.
#
# @param string $STRING
#   The string to be splitted.
#
# @param string $REGEX
#   Delimiting regular expression.
#
# @return string $result
#   String representation of an array with the splitted STRING
#
# @example
#   bfl::string_split "foo--bar" "-+" -> "( foo bar )"
#------------------------------------------------------------------------------
bfl::string_split() {
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
