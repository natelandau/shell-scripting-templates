#! /dev/null/bash

[[ "$BASH_SOURCE" =~ /bash_functions_library ]] && _bfl_temporary_var="_GUARD_BFL_$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|\1\2|')" || return 0
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
#
# Library of functions related to sms
#
# @author  Joe Mooring
#
# @file
# Defines function: bfl::send_sms_msg().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
#   Sends an SMS message via Amazon Simple Notification Service (SNS).
#
# @param String $phone_number
#   Recipient's phone number, including country code.
#
# @param String $message
#   Example: "This is line one.\\nThis is line two.\\n"
#
# @example
#   bfl::send_sms_msg "+12065550100" "Line 1.\\nLine 2."
#------------------------------------------------------------------------------
bfl::send_sms_msg() {
  bfl::verify_arg_count "$#" 2 2 || { bfl::writelog_fail "${FUNCNAME[0]} arguments count $# ≠ 2";      return ${BFL_ErrCode_Not_verified_args_count}; } # Verify argument count.
  [[ ${_BFL_HAS_AWS} -eq 1 ]]    || { bfl::writelog_fail "${FUNCNAME[0]}: dependency 'aws' not found"; return ${BFL_ErrCode_Not_verified_dependency}; } # Verify dependencies.

  # Verify argument values.
  bfl::is_blank "$1" && { bfl::writelog_fail "${FUNCNAME[0]}: recipient's phone number was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }
  bfl::is_blank "$2" && { bfl::writelog_fail "${FUNCNAME[0]}: message was not specified."; return ${BFL_ErrCode_Not_verified_arg_values}; }

  declare error_msg
  # Make sure phone number is properly formatted.
  if [[ ! "$1" =~ ^\\+[0-9]{6,}$ ]]; then
    error_msg="The recipient's phone number is improperly formatted.\\n"
    error_msg+="Expected a plus sign followed by six or more digits, received '$1'."
    bfl::writelog_fail "${FUNCNAME[0]}: '${error_msg}'"
    return $BFL_ErrCode_Not_verified_arg_values
  fi

  # Backslash escapes such as \n (newline) in the message string must be interpreted before sending the message.
  interpreted_message=$(printf "%b" "$2") || { bfl::writelog_fail "${FUNCNAME[0]}: interpreted_message=\$(printf %b '$2')"; return 1; }

  # Send the message.
  aws sns publish --phone-number "$1" --message "${interpreted_message}" || { bfl::writelog_fail "${FUNCNAME[0]}: cannot do aws sns publish --phone-number '$1' --message '${interpreted_message}')"; return 1; }
  }
