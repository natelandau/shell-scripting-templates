#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ----------------- https://github.com/ariver/bash_functions ------------------
#
# Library of functions related to cUrl
#
# @author  A. River
#
# @file
# Defines function: bfl::curl_as_ff().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Runs curl with Mozilla header.
#
# @param String $firefox_cookies
#   Firefox cookies directory.
#
# @param String $curl_args
#   curl arguments. Remainder of arguments can be pretty much anything you would otherwise provide to curl.
#
# @example
#   bfl::curl_as_ff ~/.curl/cookies_ff ...
#------------------------------------------------------------------------------
bfl::curl_as_ff ()  {
  bfl::verify_arg_count "$#" 1 999 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 999]"; return ${BFL_ErrCode_Not_verified_args_count}; }  # Verify argument count.
  [[ ${_BFL_HAS_CURL} -eq 1 ]]     || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'curl' not found";  return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: Firefox cookies is required."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r file_cookies="$1"; shift

  local -- tc_htab
  printf -v tc_htab '\t'

  local -r head_useragent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0'
  curl -A "${head_useragent}" -b "${file_cookies}" -c "${file_cookies}" $@

  return 0
  }
