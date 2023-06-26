#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to Bash Strings
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::clean_string().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Cleans a string of text.
#  Always cleaned:
#     - leading white space
#     - trailing white space
#     - multiple spaces become a single space
#     - remove spaces before and after -_
#
# @option String   -l, -u, -a, -p, -s
#     -l:  Forces all text to lowercase
#     -u:  Forces all text to uppercase
#     -a:  Removes all non-alphanumeric characters except for spaces and dashes
#     -p:  Replace one character with another (separated by commas) (escape regex characters)
#     -s:  In combination with -a, replaces characters with a space
#
# @param String $str
#   String to be cleaned.
#
# @param String $str (optional)
#   Specific characters to be removed (separated by commas, escape regex special chars).
#
# @return String $rslt
#   Prints cleaned string.
#
# @example
#   bfl::clean_string [OPT] [STRING] [CHARS TO REMOVE]
#   bfl::clean_string -lp " ,-" [STRING] [CHARS TO REMOVE]
#------------------------------------------------------------------------------
bfl::clean_string() {
  bfl::verify_arg_count "$#" 1 7 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 7]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SED} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'sed' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local opt
  local _lc=false
  local _uc=false
  local _alphanumeric=false
  local _replace=false
  local _us=false

  local OPTIND=1
  while getopts ":lLuUaAsSpP" opt; do
      case ${opt,,} in
          l ) _lc=true ;;
          u ) _uc=true ;;
          a ) _alphanumeric=true ;;
          s ) _us=true ;;
          p ) shift
              declare -a _pairs=()
              IFS=',' read -r -a _pairs <<<"$1"
              _replace=true
              ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 7]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.

  local _string="${1}"
  local _userChars="${2:-}"

  declare -a _arrayToClean=()
  IFS=',' read -r -a _arrayToClean <<<"${_userChars}"

  # trim trailing/leading white space and duplicate spaces/tabs
  _string="$(printf "%s" "${_string}" | awk '{$1=$1};1')"

  local i
  for i in "${_arrayToClean[@]}"; do
      [[ $BASH_INTERACTIVE == true ]] && printf "cleaning: ${i}" > /dev/tty
      _string="$(printf "%s" "${_string}" | sed "s/${i}//g")"
  done

  ("${_lc}") && _string=${_string,,}   # "$(printf "%s" "${_string}" | tr '[:upper:]' '[:lower:]')"
  ("${_uc}") && _string=${_string^^}   # "$(printf "%s" "${_string}" | tr '[:lower:]' '[:upper:]')"

  if "${_alphanumeric}" && "${_us}"; then
      _string="$(printf "%s" "${_string}" | tr -c '[:alnum:]_ -' ' ')"
  elif "${_alphanumeric}"; then
      _string="$(printf "%s" "${_string}" | sed "s/[^a-zA-Z0-9_ \-]//g")"
  fi

  if "${_replace}"; then
      _string="$(printf "%s" "${_string}" | sed -E "s/${_pairs[0]}/${_pairs[1]}/g")"
  fi

  # trim trailing/leading white space and duplicate dashes & spaces
  _string="$(printf "%s" "${_string}" | tr -s '-' | tr -s '_')"
  _string="$(printf "%s" "${_string}" | sed -E 's/([_\-]) /\1/g' | sed -E 's/ ([_\-])/\1/g')"
  _string="$(printf "%s" "${_string}" | awk '{$1=$1};1')"

  printf "%s\n" "${_string}"

  return 0
  }
