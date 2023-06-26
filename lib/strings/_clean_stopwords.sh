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
# Defines function: bfl::clean_stopwords().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Removes common stopwords from a string using a list of sed replacements located.
#   in an external file.  Additional stopwords can be added in arg2
#   Must have a sed file containing replacements. See: ../sedfiles/stopwords.sed
#
# @param String $str
#   String to parse.
#
# @param String $extra (optional)
#   Additional stopwords (comma separated).
#
# @return String $rslt
#   Prints string cleaned of stopwords.
#
# @example
#   CLEAN_WORD="$(bfl::clean_stopwords "[STRING]" "[MORE,STOP,WORDS]")"
#------------------------------------------------------------------------------
bfl::clean_stopwords() {
  bfl::verify_arg_count "$#" 1 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 2]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_SED} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'sed' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  sed --version | grep GNU &>/dev/null || { bfl::writelog_fail "${FUNCNAME[0]}: Required GNU sed not found. Exiting."; return 1; }

  local _sedFile="${BASH_FUNCTION_LIBRARY%/*}"/sedfiles/stopwords.sed   # $(dirname "$BASH_FUNCTION_LIBRARY")
  [[ -f "${_sedFile}" ]] || { bfl::writelog_fail "${FUNCNAME[0]}: Missing sedfile expected at: ${_sedFile}"; return 1; }

  local _w _string
  _string="$(printf "%s" "$1" | sed -f "${_sedFile}")"

  declare -a _localStopWords=()
  IFS=',' read -r -a _localStopWords <<<"${2:-}"

  if [[ ${#_localStopWords[@]} -gt 0 ]]; then
      for _w in "${_localStopWords[@]}"; do
          _string="$(printf "%s" "${_string}" | sed -E "s/\b${_w}\b//gI")"
      done
  fi

  # Remove double spaces and trim left/right
  _string="$(printf "%s" "${_string}" | sed -E 's/[ ]{2,}/ /g' | bfl::trimLR)"

  printf "%s\n" "${_string}"
  return 0
  }
