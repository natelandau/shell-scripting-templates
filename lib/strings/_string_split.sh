#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
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
#   Returns the string representation of an array, containing all fragments of STRING splitted using REGEX.
#
# @param String $STRING
#   The string to be splitted.
#
# @param String $REGEX
#   Delimiting regular expression.
#
# @return String $result
#   String representation of an array with the splitted STRING
#
# @return String $result
#   String splitted by spaces.
#
# @example
#   bfl::string_split "foo--bar" "-+" -> "( foo bar )"
#------------------------------------------------------------------------------
bfl::string_split() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2";      return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SED} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'sed' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}:${NC} no parameters";   return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$2" && { bfl::writelog_fail "${FUNCNAME[0]}:${NC} no regex string"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  # The MacOS version does not support the '-r' option but instead has the '-E' option doing the same
  if sed -r "s/-/ /" <<< "" &>/dev/null; then
    local -r SED_OPTION="-r"
  else
    local -r SED_OPTION="-E"
  fi

  echo "( $( sed ${SED_OPTION} "s/$2/ /g" <<< "$1" ) )"

#----------- https://github.com/natelandau/shell-scripting-templates ----------
#  declare -a _arr=()
#  IFS="$2" read -r -a _arr <<<"$1"
#  printf '%s\n' "${_arr[@]}"
  }
