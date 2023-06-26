#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
# - http://ryonsherman.blogspot.com/2012/10/shell-script-to-send-pushover.html-
# ---------- https://github.com/natelandau/shell-scripting-templates ----------
#
# Library of functions related to the internet
#
# @author  Nathaniel Landau
#
# @file
# Defines function: bfl::notify_pushover().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Sends a notification via Pushover.
#   NOTE:   The variables for the two API Keys must have valid values
#
# @param String $title
#   Title of notification.
#
# @param String $notification
#   Body of notification.
#
# @param String $token
#   User Token.
#
# @param String $key
#   API Key.
#
# @param String $device  (optional)
#   Device.
#
# @return Boolean $result
#     0 / 1   ( true / false )
#
# @example
#   $ bfl::notify_pushover "Title Goes Here" "Message Goes Here"
#------------------------------------------------------------------------------
bfl::notify_pushover() {
  bfl::verify_arg_count "$#" 4 5 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ∉ [4, 5]"; return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.

  local _pushoverURL="https://api.pushover.net/1/messages.json"
  local _messageTitle="${1}"
  local _message="${2}"
  local _apiKey="${3}"
  local _userKey="${4}"
  local _device="${5:-}"

  if curl \
      -F "token=${_apiKey}" \
      -F "user=${_userKey}" \
      -F "device=${_device}" \
      -F "title=${_messageTitle}" \
      -F "message=${_message}" \
      "${_pushoverURL}" >/dev/null 2>&1; then
      return 0
  fi

  return 1
  }
