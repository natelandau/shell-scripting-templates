#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------------ https://github.com/xenoxaos ------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
# ---------------- Thanks to xenoxaos for the inspiration! =] -----------------
#
# Library of functions related to cUrl
#
# @author  A. River
#
# @file
# Defines function: bfl::whoish().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs curl with web_address from http://whois.arin.net/.
#
# @param String $web_address
#   Part of http://whois.arin.net/ url.
#
# @example
#   bfl::whoish %web_address%
#------------------------------------------------------------------------------
bfl::whoish()  {
  bfl::verify_arg_count "$#" 1 999  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_CURL} -eq 1 ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'curl' not found";  return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_JQ} -eq 1 ]]        || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'jq' not found";    return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  local addr curl_cmd json jq_flt urls url
  addr="${1}"
  printf -v jq_flt %s '.nets.net' ' | ' \
          'if ( . | type ) == "object" then' \
              ' . ' \
          'elif ( . | type ) == "array" then' \
              ' .[] ' \
          'else' \
              ' "ERR" ' \
          'end' \
          ' | ' '.ref["$"] , .orgRef["$"]'

  curl_cmd=( curl -s -H 'Accept: application/json' "http://whois.arin.net/rest/nets;q=${addr}?showDetails=true" )
  json="$( "${curl_cmd[@]}" )"
  urls=( $( echo "${json}" | jq "${jq_flt}" ) )
  curl -s -H 'Accept: text/plain' "${urls[@]//\"/}" | grep -v '^#' | uniq

  return 0
  }
