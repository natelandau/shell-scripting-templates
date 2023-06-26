#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ----- https://github.com/labbots/bash-utility/blob/master/src/debug.sh ------
#----------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of internal library functions
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::print_array_to_log().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Prints the content of array as key value pairs for easier debugging. Only prints in verbose mode.
#
# @option String  -v
#   Prints array when VERBOSE is false.
#
# @param String $array_name
#   Array name.
#
# @param String $array_name  (Optional)
#   Line number where bfl::print_array_to_log is called.
#
# @return String $rslt
#   Formatted key value of array.
#
# @example
#   testArray=("1" "2" "3" "4")
#   bfl::print_array_to_log "testArray" ${LINENO}
#------------------------------------------------------------------------------
bfl::print_array_to_log() {
  bfl::verify_arg_count "$#" 1 3 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1..3]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _k opt
  local OPTIND=1
  local _printNoVerbose=false
  while getopts ":vV" opt; do
      case ${opt,,} in
          v ) _printNoVerbose=true ;;
          *)  bfl::writelog_fail "${FUNCNAME[0]}: unrecognized option '${opt}'" # "${LINENO}"
              return ${BFL_ErrCode_Not_verified_arg_values} ;;
      esac
  done
  shift $((OPTIND - 1))

  local _arrayName="${1}"
  local _lineNumber="${2:-}"
  declare -n _arr="${1}"

  ${_printNoVerbose} || [[ ${VERBOSE:-} == true ]] || return 0

  if ${_printNoVerbose}; then
      bfl::writelog_info "Contents of \${${_arrayName}[@]}" "${_lineNumber}"
      for _k in "${!_arr[@]}"; do
          bfl::writelog_info "${_k} = ${_arr[${_k}]}"
      done
  else
      bfl::writelog_debug "Contents of \${${_arrayName}[@]}" "${_lineNumber}"
      for _k in "${!_arr[@]}"; do
          bfl::writelog_debug "${_k} = ${_arr[${_k}]}"
      done
  fi
  }
