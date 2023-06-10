#!/usr/bin/env bash

! [[ "$BASH_SOURCE" =~ /bash_functions_library ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------- https://github.com/jmooring/bash-function-library -------------
# @file
# Defines function: bfl::send_sms_msg().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Sends an SMS message via Amazon Simple Notification Service (SNS).
#
# @param string $phone_number
#   Recipient's phone number, including country code.
#
# @param string $message
#   Example: "This is line one.\\nThis is line two.\\n"
#
# @example
#   bfl::send_sms_msg "+12065550100" "Line 1.\\nLine 2."
#------------------------------------------------------------------------------
bfl::send_sms_msg() {
  bfl::verify_arg_count "$#" 2 2 || bfl::die "Arguments count for ${FUNCNAME[0]} not satisfy == 2"  # Verify argument count.
  bfl::verify_dependencies "aws"

  [[ -z "$1" ]] && bfl::die "The recipient's phone number was not specified."
  [[ -z "$2" ]] && bfl::die "The message was not specified."

  declare error_msg
  # Make sure phone number is properly formatted.
  if [[ ! "$1" =~ ^\\+[0-9]{6,}$ ]]; then
    error_msg="The recipient's phone number is improperly formatted.\\n"
    error_msg+="Expected a plus sign followed by six or more digits, received $1."
    bfl::die "$error_msg"
  fi

  # Backslash escapes such as \n (newline) in the message string must be
  # interpreted before sending the message.
  interpreted_message=$(printf "%b" "$2") || bfl::die

  # Send the message.
  aws sns publish --phone-number "$1" --message "$interpreted_message" || bfl::die
  }
