#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to manipulations with files
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_file_part().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints text of a file between two regex patterns.
#
# @option String  -i, -r, -g
#      -i  Case-insensitive regex
#      -r  Remove first and last lines (ie - the lines which matched the patterns)
#      -g  Greedy regex (Defaults to non-greedy)
#
# @param String $regex_from
#   Starting regex pattern.
#
# @param String $regex_to
#   Ending regex pattern.
#
# @param String $filename
#   Input string.
#
# @return String $rslt
#   Prints text between two regex patterns.
#
# @example
#   bfl::get_file_part "^pattern1$" "^pattern2$" "String or variable containing a string"
#------------------------------------------------------------------------------
bfl::get_file_part() {
  bfl::verify_arg_count "$#" 3 6 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [3, 6]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _removeLines=false
  local _greedy=false
  local _caseInsensitive=false
  local opt
  local OPTIND=1
  while getopts ":iIrRgG" opt; do
      case ${opt,,} in
          i ) _caseInsensitive=true ;;
          r ) _removeLines=true ;;
          g ) _greedy=true ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: regex mask '$1' is blank!";    return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$2" && { bfl::writelog_fail "${FUNCNAME[0]}: regex mask '$2' is blank!";    return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$3" && { bfl::writelog_fail "${FUNCNAME[0]}: path '$3' was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -f "$3" ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: path '$3' doesn't exists!";    return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -s "$3" ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: path '$3' is empty!";          return ${BFL_ErrCode_Not_verified_arg_values}; }

  local _startRegex="${1}"
  local _endRegex="${2}"
  local _input="${3}"
  local _output

  if [[ ${_removeLines} == true ]]; then
      if [[ ${_greedy} == true ]]; then
          if [[ ${_caseInsensitive} == true ]]; then
              _output="$(sed '1d' "${_input}" | sed '$d' | sed -nE "/${_startRegex}/I,/${_endRegex}/Ip")"
          else
              _output="$(sed '1d' "${_input}" | sed '$d' | sed -nE "/${_startRegex}/,/${_endRegex}/p")"
          fi
      else
          if [[ ${_caseInsensitive} == true ]]; then
              _output="$(sed '1d' "${_input}" | sed '$d' | sed -nE "/${_startRegex}/I,/${_endRegex}/I{p;/${_endRegex}/Iq}")"
          else
              _output="$(sed '1d' "${_input}" | sed '$d' | sed -nE "/${_startRegex}/,/${_endRegex}/{p;/${_endRegex}/q}")"
          fi
      fi
  else
      if [[ ${_greedy} == true ]]; then
          if [[ ${_caseInsensitive} == true ]]; then
              _output="$(sed -nE "/${_startRegex}/I,/${_endRegex}/Ip" "${_input}")"
          else
              _output="$(sed -nE "/${_startRegex}/,/${_endRegex}/p" "${_input}")"
          fi
      else
          if [[ ${_caseInsensitive} == true ]]; then
              _output="$(sed -nE "/${_startRegex}/I,/${_endRegex}/I{p;/${_endRegex}/Iq}" "${_input}")"
          else
              _output="$(sed -nE "/${_startRegex}/,/${_endRegex}/{p;/${_endRegex}/q}" "${_input}")"
          fi
      fi
  fi

  local s1 s2
  if [[ ${_caseInsensitive} == true ]]; then
      s1="$(echo "${_output}" | sed -nE "/${_startRegex}/Ip")"
      s2="$(echo "${_output}" | sed -nE "/${_endRegex}/Ip")"
  else
      s1="$(echo "${_output}" | sed -n "/${_startRegex}/p")"
      s2="$(echo "${_output}" | sed -n "/${_endRegex}/p")"
  fi

  [[ -n "$s1" && -n "$s2" ]] || return 0
  [[ -n ${_output:-} ]] && { printf "%s\n" "${_output}"; return 0; }

  return 1
  }
