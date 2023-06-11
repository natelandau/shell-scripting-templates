#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
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
  bfl::verify_arg_count "$#" 2 2 || bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2" && return 1 # Verify argument count.

  # Verify argument values.
  bfl::is_blank "$1" && bfl::writelog_fail "${FUNCNAME[0]}:${NC} no parameters" && return 1
  bfl::is_blank "$2" && bfl::writelog_fail "${FUNCNAME[0]}:${NC} no regex string" && return 1

  # The MacOS version does not support the '-r' option but instead has the '-E' option doing the same
  if sed -r "s/-/ /" <<< "" &>/dev/null; then
    local -r SED_OPTION="-r"
  else
    local -r SED_OPTION="-E"
  fi

  echo "( $( sed ${SED_OPTION} "s/$2/ /g" <<< "$1" ) )"
  }
