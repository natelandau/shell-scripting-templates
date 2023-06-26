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
# Defines function: bfl::curl_cookies_ff_upup().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   ..............................
#
# @param String $firefox_profiles
#   Firefox profiles directory.
#
# @param String $firefox_cookies  (may be not exists)
#   Firefox cookies directory.
#
# @example
#   bfl::curl_cookies_ff_upup "$HOME/Library/Application Support/Firefox/Profiles" ~/.curl/cookies_ff
#------------------------------------------------------------------------------
bfl::curl_cookies_ff_upup ()  {
  bfl::verify_arg_count "$#" 2 2  || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2";          return $BFL_ErrCode_Not_verified_args_count;   }  # Verify argument count.
  [[ ${_BFL_HAS_CURL} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'curl' not found";    return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.
  [[ ${_BFL_HAS_SQLITE3} -eq 1 ]] || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'sqlite3' not found"; return ${BFL_ErrCode_Not_verified_dependency}; }  # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: Firefox profiles folder is required.";         return ${BFL_ErrCode_Not_verified_arg_values}; }
  [[ -d "$1" ]]      || { bfl::writelog_fail "${FUNCNAME[0]}: Firefox profiles folder '$1' doesn't exist!";  return ${BFL_ErrCode_Not_verified_arg_values}; }
  install -v -d "${2%/*}" || { bfl::writelog_fail "${FUNCNAME[0]}: Firefox cookies '$2' cannot be created!"; return ${BFL_ErrCode_Not_verified_arg_values}; }

  local -r firefox_cookies="$2"

  local -- tc_htab
  local -- ff_profile

  printf -v tc_htab '\t'

  ff_profile="$(find "$1"/*.default/. -maxdepth 0 -type d -print0 | xargs -0 ls -1drt | tail -1)"

  command cp -af "${firefox_cookies}"{,.0} 2>/dev/null

          #'select host, "TRUE", path, case isSecure when 0 then "FALSE" else "TRUE" end, expiry, name, value from moz_cookies'
  sqlite3 -separator "${tc_htab}" \
          "${ff_profile}/cookies.sqlite" \
          "select \
                host as domain, \
                case substr(host,1,1)='.' when 0 then 'FALSE' else 'TRUE' end as flag, \
                path, \
                case isSecure when 0 then 'FALSE' else 'TRUE' end as secure, \
                expiry as expiration, name, value \
           from moz_cookies" \
      > "${firefox_cookies}".1

  cat "${firefox_cookies}".[01] 2>/dev/null \
      | grep -n . \
      | sort -t: -k 2,99 -k 1,1gr \
      | sort -t: -k 2,99 -u \
      | sort -t: -k 1,1g \
      | cut -d: -f2- \
      > "${firefox_cookies}".9

  diff "${firefox_cookies}"{,.9} 2>/dev/null

  [[ $? -ne 0 && -s "${firefox_cookies}".9 ]] && { command cp -vf "${firefox_cookies}"{.9,}; }
  command rm -vf "${firefox_cookies}".?

  return 0
  }
