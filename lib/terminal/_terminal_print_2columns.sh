#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to terminal
#
#
#
# @file
# Defines function: bfl::terminal_print_2columns().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints a two column output with fixed widths and wrapping text from a key/value pair.
#   Optionally pass a number of 2 space tabs to indent the output.
#
# @option String -b
#   Bold the left column.
#
# @option String -u
#   Underline the left column.
#
# @option String -r
#   Reverse background and foreground colors.
#
# @param String $key_name
#   Key name (Left column text).
#
# @param String $value
#   Long value (Right column text. Wraps around if too long).
#
# @param String $tabLevel
#   Number of 2 character tabs to indent the command (default 1).
#
# @param String $leftColumnWidth
#   Total character width of the left column (default 35).
#
# @return String $rslt
#   Prints the output in columns. Long text or ANSI colors in the first column may create display issues.
#
# @example
#   bfl::terminal_print_2columns -b -u "Key" "Long value text" [tab level]
#------------------------------------------------------------------------------
bfl::terminal_print_2columns() {
  bfl::verify_arg_count "$#" 2 7 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [2..7]";  return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_TPUT} -eq 1 ]]   || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'tput' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify options.
  local opt
  local OPTIND=1
  local _style=""
  while getopts ":bBuUrR" opt; do
      case "${opt,,}" in
          b ) _style="${_style}${bold}" ;;
          u ) _style="${_style}${underline}" ;;
          r ) _style="${_style}${reverse}" ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  local _key="$1"
  local _value="$2"
  local -i _tabLevel="${3:-0}"
  local -i _leftColumnWidth=${4:-35}
  local -i _tabSize=2
  local -i _leftIndent=$((_tabLevel * _tabSize))
  _leftColumnWidth=$((_leftColumnWidth - _leftIndent))
  local -i i=$(tput cols)
  local -i _rightIndent
  if [[ ${i} -gt 180 ]]; then
      _rightIndent=110
  elif [[ ${i} -gt 160 ]]; then
      _rightIndent=90
  elif [[ ${i} -gt 130 ]]; then
      _rightIndent=60
  else
      local -i k=$((i/10))
      [[ ${i} -gt 70 ]] && _rightIndent=$((k*10-70)) || _rightIndent=0
  fi

  local -i _rightWrapLength=$((i - _leftColumnWidth - _leftIndent - _rightIndent))
  local -i _first_line=0
  local _line
  while read -r _line; do
      [[ ${_first_line} -eq 0 ]] && _first_line=1 || _key=" "
      printf "%-${_leftIndent}s${_style}%-${_leftColumnWidth}b${reset} %b\n" "" "${_key}${reset}" "${_line}"
  done <<<"$(fold -w${_rightWrapLength} -s <<<"${_value}")"
  }
