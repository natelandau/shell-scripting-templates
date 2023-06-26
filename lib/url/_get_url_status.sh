#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# ------------------- https://gist.github.com/rsvp/1171304 --------------------
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to the internet
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::get_url_status().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Reports the HTTP status of a specified URL.
#
# @param String $url
#   URL (will work fine without https:// prefix).
#
# @param String $seconds  (optional)
#   Seconds to wait until timeout (Default is 3).
#
# @param String $code  (optional)
#   either '--code'  or '--status' (default).
#
# @param String $curl_opts  (optional)
#   CURL opts separated by spaces (Use -L to follow redirects).
#
# @return Integer $result
#   Prints the HTTP status code or status message
#
# @example
#   printf "%s\n" "$(bfl::get_url_status URL [timeout] [--code or --status] [curl opts]
#   $ bfl::get_url_status bit.ly
#   301 Redirection: Moved Permanently
#
#   $ _httpStatus_ www.google.com 100 --code
#------------------------------------------------------------------------------
bfl::get_url_status() {
  bfl::verify_arg_count "$#" 1 7 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [1, 7]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _saveIFS=${IFS}
  IFS=$' \n\t'

  local _url="${1}"
  local _timeout=${2:-3}
  local _flag=${3:---status}
  local _arg4="${4:-}"
  local _arg5="${5:-}"
  local _arg6="${6:-}"
  local _arg7="${7:-}"
  local _curlops="${_arg4} ${_arg5} ${_arg6} ${_arg7}"
  local _code _status

  #      __________ get the CODE which is numeric:
  # shellcheck disable=SC1083
  _code=$(curl --write-out %{http_code} --silent --connect-timeout "${_timeout}" --no-keepalive "${_curlops}" --output /dev/null "${_url}")

  #      __________ get the STATUS (from code) which is human interpretable:
  case ${_code} in
      000) _status="Not responding within ${_timeout} seconds" ;;
      100) _status="Informational: Continue" ;;
      101) _status="Informational: Switching Protocols" ;;
      200) _status="Successful: OK within ${_timeout} seconds" ;;
      201) _status="Successful: Created" ;;
      202) _status="Successful: Accepted" ;;
      203) _status="Successful: Non-Authoritative Information" ;;
      204) _status="Successful: No Content" ;;
      205) _status="Successful: Reset Content" ;;
      206) _status="Successful: Partial Content" ;;
      300) _status="Redirection: Multiple Choices" ;;
      301) _status="Redirection: Moved Permanently" ;;
      302) _status="Redirection: Found residing temporarily under different URI" ;;
      303) _status="Redirection: See Other" ;;
      304) _status="Redirection: Not Modified" ;;
      305) _status="Redirection: Use Proxy" ;;
      306) _status="Redirection: status not defined" ;;
      307) _status="Redirection: Temporary Redirect" ;;
      400) _status="Client Error: Bad Request" ;;
      401) _status="Client Error: Unauthorized" ;;
      402) _status="Client Error: Payment Required" ;;
      403) _status="Client Error: Forbidden" ;;
      404) _status="Client Error: Not Found" ;;
      405) _status="Client Error: Method Not Allowed" ;;
      406) _status="Client Error: Not Acceptable" ;;
      407) _status="Client Error: Proxy Authentication Required" ;;
      408) _status="Client Error: Request Timeout within ${_timeout} seconds" ;;
      409) _status="Client Error: Conflict" ;;
      410) _status="Client Error: Gone" ;;
      411) _status="Client Error: Length Required" ;;
      412) _status="Client Error: Precondition Failed" ;;
      413) _status="Client Error: Request Entity Too Large" ;;
      414) _status="Client Error: Request-URI Too Long" ;;
      415) _status="Client Error: Unsupported Media Type" ;;
      416) _status="Client Error: Requested Range Not Satisfiable" ;;
      417) _status="Client Error: Expectation Failed" ;;
      500) _status="Server Error: Internal Server Error" ;;
      501) _status="Server Error: Not Implemented" ;;
      502) _status="Server Error: Bad Gateway" ;;
      503) _status="Server Error: Service Unavailable" ;;
      504) _status="Server Error: Gateway Timeout within ${_timeout} seconds" ;;
      505) _status="Server Error: HTTP Version Not Supported" ;;
      *) bfl::writelog_fail "${FUNCNAME[0]}: httpstatus not defined."; return 1 ;;
  esac

  case ${_flag} in
      --status) printf "%s %s\n" "${_code}" "${_status}" ;;
      -s)       printf "%s %s\n" "${_code}" "${_status}" ;;
      --code)   printf "%s\n" "${_code}" ;;
      -c)       printf "%s\n" "${_code}" ;;
      *)        bfl::writelog_fail "${FUNCNAME[0]}: curl: bad flag ${_flag}"
                return 1 ;;
  esac

  IFS="${_saveIFS}"
  return 0
  }
